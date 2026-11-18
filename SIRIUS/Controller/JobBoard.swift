//
//  JobBoard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation
import Combine

struct AppliedJob: Identifiable {
    let id: String
    let position: String
    let company: String
    let percentage: Int
}

struct AutoApplyOutcome {
    var applied: [AppliedJob] = []
    var failed = false
}

private struct BoardSnapshot: Codable {
    var jobs: [Job]
    var applications: [ApplicationRecord]
    var interviews: [Interview]
}

final class JobBoard: ObservableObject {

    static let shared = JobBoard()

    @Published private(set) var jobs: [Job] = []
    @Published private(set) var applications: [ApplicationRecord] = []
    @Published private(set) var interviews: [Interview] = []
    @Published private(set) var didLoad = false

    @Published private(set) var loadState: LoadState = .loaded
    @Published var syncError: String?

    init() {}

    // MARK: - Supabase sync

    private var lastOperation: Task<Void, Never>?
    private var cachedUserID: UUID?

    @MainActor
    private func restoreCache(for userID: UUID) {
        guard cachedUserID != userID else { return }
        cachedUserID = userID
        guard jobs.isEmpty, applications.isEmpty,
              let snapshot = LocalSnapshot.load(BoardSnapshot.self, name: "board", userID: userID) else { return }
        jobs = snapshot.jobs
        applications = snapshot.applications
        interviews = snapshot.interviews
    }

    private func remote(_ operation: @escaping () async throws -> Void) {
        let previous = lastOperation
        lastOperation = Task { @MainActor in
            await previous?.value
            do {
                try await operation()
            } catch {
                self.syncError = "Couldn't save your changes. Check your connection and try again."
            }
            await self.reload(silent: true)
        }
    }

    @MainActor
    func reload(silent: Bool = false) async {
        guard let userID = await SupabaseAuthService.currentUserID() else {
            loadState = .loaded
            return
        }
        restoreCache(for: userID)
        if !silent && jobs.isEmpty && applications.isEmpty {
            loadState = .loading
        }
        do {
            let board = try await SupabaseStore.fetchBoard()
            jobs = board.jobs
            applications = board.applications
            interviews = board.interviews
            loadState = .loaded
            didLoad = true
            LocalSnapshot.save(
                BoardSnapshot(jobs: board.jobs, applications: board.applications, interviews: board.interviews),
                name: "board",
                userID: userID
            )
        } catch {
            if silent { return }
            if !jobs.isEmpty || !applications.isEmpty {
                loadState = .loaded
                return
            }
            loadState = .failed(SupabaseAuthService.accountError(from: error).errorDescription ?? "Couldn't load your data.")
        }
    }

    func clear() {
        lastOperation?.cancel()
        lastOperation = nil
        if let userID = cachedUserID { LocalSnapshot.remove(name: "board", userID: userID) }
        cachedUserID = nil
        jobs = []
        applications = []
        interviews = []
        loadState = .loaded
        didLoad = false
        syncError = nil
    }

    func interview(forRecord recordID: UUID) -> Interview? {
        interviews.last { $0.applicantID == recordID }
    }

    func record(withID id: UUID) -> ApplicationRecord? {
        applications.first { $0.id == id }
    }

    // MARK: - Lookups

    func job(withID id: String) -> Job? {
        jobs.first { $0.jobID == id }
    }

    func activeJobs() -> [Job] {
        jobs.filter { $0.isActive }
    }

    func jobs(forCompany companyID: String) -> [Job] {
        jobs.filter { $0.companyID == companyID }
    }

    func applications(forJob jobID: String) -> [ApplicationRecord] {
        applications.filter { $0.jobID == jobID && !$0.isRemoved && !$0.isWithdrawn }
    }

    func applications(forApplicant applicantID: UUID) -> [ApplicationRecord] {
        applications.filter { $0.applicantID == applicantID }
    }

    func applicantCount(forJob jobID: String) -> Int {
        applications(forJob: jobID).count
    }

    func count(forJob jobID: String, status: EmpAplStatus) -> Int {
        applications(forJob: jobID).filter { $0.status == status }.count
    }

    func hasApplied(applicantID: UUID, jobID: String) -> Bool {
        applications.contains { $0.applicantID == applicantID && $0.jobID == jobID }
    }

    func hasActiveApplication(applicantID: UUID, jobID: String) -> Bool {
        applications.contains {
            $0.applicantID == applicantID && $0.jobID == jobID && !$0.isWithdrawn && !$0.isRemoved
        }
    }

    func breakdown(for applicant: Applicant, job: Job) -> MatchBreakdown {
        Matching.evaluate(applicant.matchProfile, against: job.matchRequirements)
    }

    // MARK: - Jobs

    func addJob(_ job: Job) {
        jobs.insert(job, at: 0)
        remote { try await SupabaseStore.insertJob(job) }
    }

    func updateJob(_ job: Job) {
        guard let index = jobs.firstIndex(where: { $0.jobID == job.jobID }) else { return }
        var merged = job
        merged.isActive = jobs[index].isActive
        merged.datePosted = jobs[index].datePosted
        merged.companyID = jobs[index].companyID
        merged.companyName = jobs[index].companyName
        merged.isFilled = jobs[index].isFilled
        if merged.isFilled && count(forJob: merged.jobID, status: .hired) < merged.maxHire {
            merged.isFilled = false
        }

        jobs[index] = merged
        for position in applications.indices where applications[position].jobID == merged.jobID {
            let record = applications[position]
            applications[position].breakdown = Matching.evaluate(record.matchProfile, against: merged.matchRequirements)
        }
        let saved = merged
        remote {
            try await SupabaseStore.updateJob(saved)
        }
    }

    @discardableResult
    func setActive(jobID: String, isActive: Bool) -> Bool {
        guard let index = jobs.firstIndex(where: { $0.jobID == jobID }) else { return false }
        if isActive && count(forJob: jobID, status: .hired) >= jobs[index].maxHire {
            return false
        }
        jobs[index].isFilled = false
        jobs[index].isActive = isActive
        remote {
            try await SupabaseStore.setJobStatus(jobID: jobID, isActive: isActive, isFilled: false)
        }
        return true
    }

    func deleteJob(jobID: String) {
        let removedIDs = Set(applications.filter { $0.jobID == jobID }.map { $0.id })
        jobs.removeAll { $0.jobID == jobID }
        applications.removeAll { $0.jobID == jobID }
        interviews.removeAll { removedIDs.contains($0.applicantID) }
        remote { try await SupabaseStore.deleteJob(jobID: jobID) }
    }

    // MARK: - Controlled applications

    static let applyBatchSize = 10

    func pendingQualifiedJobs(for applicant: Applicant) -> [(job: Job, breakdown: MatchBreakdown)] {
        func locationRank(_ b: MatchBreakdown) -> Int { (b.locationMatches ?? false) ? 0 : 1 }
        return activeJobs()
            .filter { !hasApplied(applicantID: applicant.id, jobID: $0.jobID) }
            .map { (job: $0, breakdown: breakdown(for: applicant, job: $0)) }
            .filter { $0.breakdown.isEligible }
            .sorted {
                if $0.breakdown.total != $1.breakdown.total { return $0.breakdown.total > $1.breakdown.total }
                if locationRank($0.breakdown) != locationRank($1.breakdown) { return locationRank($0.breakdown) < locationRank($1.breakdown) }
                return $0.job.datePosted > $1.job.datePosted
            }
    }

    @MainActor
    func autoApply(applicant: Applicant, limit: Int = JobBoard.applyBatchSize) async -> AutoApplyOutcome {
        await reload(silent: true)
        let picks = Array(pendingQualifiedJobs(for: applicant).prefix(limit))
        guard !picks.isEmpty else { return AutoApplyOutcome() }
        do {
            try await SupabaseStore.applyToJobs(picks.map { (jobID: $0.job.jobID, score: $0.breakdown.total) })
        } catch {
            syncError = "Couldn't send your applications. Check your connection and try again."
            return AutoApplyOutcome(failed: true)
        }
        await reload(silent: true)
        let applied = picks.map {
            AppliedJob(
                id: $0.job.jobID,
                position: $0.job.jobPos,
                company: $0.job.companyName.isEmpty ? "Company" : $0.job.companyName,
                percentage: $0.breakdown.total
            )
        }
        return AutoApplyOutcome(applied: applied)
    }

    @MainActor
    @discardableResult
    func applyToQualifiedJobs(applicant: Applicant, limit: Int = JobBoard.applyBatchSize) async -> Int {
        await autoApply(applicant: applicant, limit: limit).applied.count
    }

    // MARK: - Employer actions

    func scheduleInterview(recordID: UUID, date: Date, location: String, message: String) {
        guard let index = applications.firstIndex(where: { $0.id == recordID }),
              applications[index].status == .toReview else { return }
        interviews.append(Interview(applicantID: recordID, date: date, location: location, message: message))
        applications[index].status = .interview
        remote { try await SupabaseStore.setInterview(recordID: recordID, date: date, location: location, message: message) }
    }

    @discardableResult
    func scheduleInterviews(recordIDs: [UUID], date: Date, location: String, message: String) -> Int {
        var sent: [UUID] = []
        for id in recordIDs {
            guard let index = applications.firstIndex(where: { $0.id == id }),
                  applications[index].status == .toReview,
                  !applications[index].isRemoved,
                  !applications[index].isWithdrawn else { continue }
            interviews.append(Interview(applicantID: id, date: date, location: location, message: message))
            applications[index].status = .interview
            sent.append(id)
        }
        guard !sent.isEmpty else { return 0 }
        remote { try await SupabaseStore.setInterviews(recordIDs: sent, date: date, location: location, message: message) }
        return sent.count
    }

    func hire(recordID: UUID) -> HireResult {
        guard let index = applications.firstIndex(where: { $0.id == recordID }) else { return .notFound }
        guard applications[index].status == .interview else { return .notInInterview }
        guard let job = job(withID: applications[index].jobID) else { return .notFound }
        if count(forJob: job.jobID, status: .hired) >= job.maxHire {
            return .jobFull(maxHire: job.maxHire)
        }
        applications[index].status = .hired
        let closesJob = count(forJob: job.jobID, status: .hired) >= job.maxHire
        if closesJob, let jobIndex = jobs.firstIndex(where: { $0.jobID == job.jobID }) {
            jobs[jobIndex].isActive = false
            jobs[jobIndex].isFilled = true
        }
        let jobID = job.jobID
        remote {
            try await SupabaseStore.setStatus(recordID: recordID, status: .hired)
            if closesJob { try await SupabaseStore.setJobStatus(jobID: jobID, isActive: false, isFilled: true) }
        }
        return .hired
    }

    func remove(recordID: UUID, reason: String = "") {
        guard let index = applications.firstIndex(where: { $0.id == recordID }) else { return }
        let cleanReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        applications[index].isRemoved = true
        applications[index].rejectionReason = cleanReason
        interviews.removeAll { $0.applicantID == recordID }
        remote { try await SupabaseStore.removeApplication(recordID: recordID, reason: cleanReason) }
    }

    func rescheduleInterview(recordID: UUID, date: Date, location: String, message: String) {
        guard let index = applications.firstIndex(where: { $0.id == recordID }),
              applications[index].status == .interview else { return }
        if let interviewIndex = interviews.lastIndex(where: { $0.applicantID == recordID }) {
            interviews[interviewIndex].date = date
            interviews[interviewIndex].location = location
            interviews[interviewIndex].message = message
        } else {
            interviews.append(Interview(applicantID: recordID, date: date, location: location, message: message))
        }
        remote { try await SupabaseStore.setInterview(recordID: recordID, date: date, location: location, message: message) }
    }

    // MARK: - Applicant actions

    @discardableResult
    func withdraw(recordID: UUID) -> Bool {
        guard let index = applications.firstIndex(where: { $0.id == recordID }),
              applications[index].status != .hired,
              !applications[index].isRemoved else { return false }
        applications[index].isWithdrawn = true
        interviews.removeAll { $0.applicantID == recordID }
        remote { try await SupabaseStore.withdrawApplication(recordID: recordID) }
        return true
    }
}
