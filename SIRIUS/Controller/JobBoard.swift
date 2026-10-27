//
//  JobBoard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation
import Combine

final class JobBoard: ObservableObject {
    
    static let shared = JobBoard()
    
    @Published private(set) var jobs: [Job] = []
    @Published private(set) var applications: [ApplicationRecord] = []
    @Published private(set) var interviews: [Interview] = []
    
    // Loading / error state for the lists (screens show a spinner or a retry card)
    @Published private(set) var loadState: LoadState = .loaded
    // Set when a write could not reach the server; the app shows a dismissible banner
    @Published var syncError: String?
    
    init() {}
    
    // MARK: - Supabase sync
    
    private var lastOperation: Task<Void, Never>?
    
    // Runs one database write after the previous one finished, then refreshes from the server.
    // The screens update immediately (optimistic); if the write fails the refresh puts the real data back.
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
    
    // Fetches jobs, applications and interviews. Row Level Security returns only what this user may see.
    @MainActor
    func reload(silent: Bool = false) async {
        guard await SupabaseAuthService.currentUserID() != nil else {
            loadState = .loaded
            return
        }
        if !silent && jobs.isEmpty && applications.isEmpty {
            loadState = .loading
        }
        do {
            let board = try await SupabaseStore.fetchBoard()
            jobs = board.jobs
            applications = board.applications
            interviews = board.interviews
            loadState = .loaded
        } catch {
            if silent { return }
            loadState = .failed(SupabaseAuthService.accountError(from: error).errorDescription ?? "Couldn't load your data.")
        }
    }
    
    // Called on log out so the next user does not see the previous user's data
    func clear() {
        lastOperation?.cancel()
        lastOperation = nil
        jobs = []
        applications = []
        interviews = []
        loadState = .loaded
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
    
    // Applications an employer can see for one job (removed ones are hidden)
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
    
    // Applied and not withdrawn / rejected
    func hasActiveApplication(applicantID: UUID, jobID: String) -> Bool {
        applications.contains {
            $0.applicantID == applicantID && $0.jobID == jobID && !$0.isWithdrawn && !$0.isRemoved
        }
    }
    
    func breakdown(for applicant: Applicant, job: Job) -> MatchBreakdown {
        Matching.evaluate(applicant.matchProfile, against: job.matchRequirements)
    }
    
    // MARK: - Jobs
    
    // Adds a job. The server then applies every matching applicant (>= 60%).
    func addJob(_ job: Job) {
        jobs.insert(job, at: 0)
        remote {
            try await SupabaseStore.insertJob(job)
            try await SupabaseStore.autoApply(jobID: job.jobID)
        }
    }
    
    // Replaces an edited job (same jobID). The server refreshes scores and applies any applicant who now matches.
    func updateJob(_ job: Job) {
        guard let index = jobs.firstIndex(where: { $0.jobID == job.jobID }) else { return }
        var merged = job
        merged.isActive = jobs[index].isActive          // status changes only through setActive
        merged.datePosted = jobs[index].datePosted
        merged.companyID = jobs[index].companyID
        merged.companyName = jobs[index].companyName
        merged.isFilled = jobs[index].isFilled
        // Raising the maximum above the current hires lifts the "filled" flag (job stays inactive until reactivated)
        if merged.isFilled && count(forJob: merged.jobID, status: .hired) < merged.maxHire {
            merged.isFilled = false
        }
        jobs[index] = merged
        // Stored percentages follow the new requirements
        for position in applications.indices where applications[position].jobID == merged.jobID {
            let record = applications[position]
            applications[position].breakdown = Matching.evaluate(record.matchProfile, against: merged.matchRequirements)
        }
        let saved = merged
        remote {
            try await SupabaseStore.updateJob(saved)
            try await SupabaseStore.autoApply(jobID: saved.jobID)
        }
    }
    
    // Returns false when the job cannot be reopened because every position is already filled
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
            if isActive { try await SupabaseStore.autoApply(jobID: jobID) }
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
    
    // MARK: - Automatic applications
    
    // Asks the server to apply the signed-in applicant to every active job they match at 60% or more
    // (and to refresh the stored scores after a profile edit), then reloads.
    @MainActor
    func autoApply(applicant: Applicant) async {
        do {
            try await SupabaseStore.autoApplyCurrentApplicant()
        } catch {
            syncError = "Couldn't check your matches. Check your connection and try again."
        }
        await reload(silent: true)
    }
    
    // MARK: - Employer actions
    
    func scheduleInterview(recordID: UUID, date: Date, location: String, message: String) {
        guard let index = applications.firstIndex(where: { $0.id == recordID }),
              applications[index].status == .toReview else { return }
        interviews.append(Interview(applicantID: recordID, date: date, location: location, message: message))
        applications[index].status = .interview
        remote { try await SupabaseStore.setInterview(recordID: recordID, date: date, location: location, message: message) }
    }
    
    func hire(recordID: UUID) -> HireResult {
        guard let index = applications.firstIndex(where: { $0.id == recordID }) else { return .notFound }
        guard applications[index].status == .interview else { return .notInInterview }
        guard let job = job(withID: applications[index].jobID) else { return .notFound }
        if count(forJob: job.jobID, status: .hired) >= job.maxHire {
            return .jobFull(maxHire: job.maxHire)
        }
        applications[index].status = .hired
        // Every position filled: close the job so it leaves the applicant feed
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
    
    // Employer rejects / removes an applicant. The reason is shown to the applicant.
    func remove(recordID: UUID, reason: String = "") {
        guard let index = applications.firstIndex(where: { $0.id == recordID }) else { return }
        let cleanReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        applications[index].isRemoved = true
        applications[index].rejectionReason = cleanReason
        interviews.removeAll { $0.applicantID == recordID }
        remote { try await SupabaseStore.removeApplication(recordID: recordID, reason: cleanReason) }
    }
    
    // Moves an existing interview to a new date / place and keeps the applicant in Interview
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
    
    // The applicant withdraws. Hired applications cannot be withdrawn here.
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
