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
    
    init() {}
    
    // TODO(Supabase): push the changed rows to the database here.
    private func save() {}
    
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
        applications.filter { $0.jobID == jobID && !$0.isRemoved }
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
    
    func breakdown(for applicant: Applicant, job: Job) -> MatchBreakdown {
        Matching.evaluate(applicant.matchProfile, against: job.matchRequirements)
    }
    
    // MARK: - Jobs
    
    // Adds a job and automatically applies every matching applicant (>= 60%).
    @discardableResult
    func addJob(_ job: Job, applicants: [Applicant]) -> [ApplicationRecord] {
        jobs.insert(job, at: 0)
        let created = autoApplyInternal(job: job, applicants: applicants)
        save()
        return created
    }
    
    // Replaces an edited job (same jobID) and applies any applicant who now matches.
    @discardableResult
    func updateJob(_ job: Job, applicants: [Applicant]) -> [ApplicationRecord] {
        guard let index = jobs.firstIndex(where: { $0.jobID == job.jobID }) else { return [] }
        var merged = job
        merged.isActive = jobs[index].isActive          // status changes only through setActive
        merged.datePosted = jobs[index].datePosted
        merged.companyID = jobs[index].companyID
        merged.companyName = jobs[index].companyName
        jobs[index] = merged
        let created = autoApplyInternal(job: merged, applicants: applicants)
        // Stored percentages follow the new requirements
        for position in applications.indices where applications[position].jobID == merged.jobID {
            let record = applications[position]
            let profile = MatchProfile(program: record.degree, yearsExperience: record.yearsExperience, languages: record.languages)
            applications[position].breakdown = Matching.evaluate(profile, against: merged.matchRequirements)
        }
        save()
        return created
    }
    
    func setActive(jobID: String, isActive: Bool, applicants: [Applicant]) {
        guard let index = jobs.firstIndex(where: { $0.jobID == jobID }) else { return }
        jobs[index].isActive = isActive
        if isActive {
            _ = autoApplyInternal(job: jobs[index], applicants: applicants)
        }
        save()
    }
    
    func deleteJob(jobID: String) {
        let removedIDs = Set(applications.filter { $0.jobID == jobID }.map { $0.id })
        jobs.removeAll { $0.jobID == jobID }
        applications.removeAll { $0.jobID == jobID }
        interviews.removeAll { removedIDs.contains($0.applicantID) }
        save()
    }
    
    // MARK: - Automatic applications
    
    // Applies one applicant to every active job they match at 60% or more.
    @discardableResult
    func autoApply(applicant: Applicant) -> [ApplicationRecord] {
        var created: [ApplicationRecord] = []
        for job in activeJobs() {
            if let record = applyIfEligible(applicant, to: job) {
                created.append(record)
            }
        }
        refreshSnapshot(of: applicant)
        save()
        return created
    }
    
    private func autoApplyInternal(job: Job, applicants: [Applicant]) -> [ApplicationRecord] {
        guard job.isActive else { return [] }
        return applicants.compactMap { applyIfEligible($0, to: job) }
    }
    
    // Never creates a second application for the same applicant + job.
    private func applyIfEligible(_ applicant: Applicant, to job: Job) -> ApplicationRecord? {
        guard !hasApplied(applicantID: applicant.id, jobID: job.jobID) else { return nil }
        let result = breakdown(for: applicant, job: job)
        guard result.total >= MatchRules.autoApplyThreshold else { return nil }
        
        let record = ApplicationRecord(
            jobID: job.jobID,
            applicantID: applicant.id,
            applicantName: applicant.fullName,
            degree: applicant.program,
            yearsExperience: applicant.yrExp,
            languages: applicant.coreLang,
            breakdown: result
        )
        applications.append(record)
        return record
    }
    
    // Keeps stored applicant details in sync after the applicant edits their profile.
    private func refreshSnapshot(of applicant: Applicant) {
        for index in applications.indices where applications[index].applicantID == applicant.id {
            guard let job = job(withID: applications[index].jobID) else { continue }
            applications[index].applicantName = applicant.fullName
            applications[index].degree = applicant.program
            applications[index].yearsExperience = applicant.yrExp
            applications[index].languages = applicant.coreLang
            applications[index].breakdown = breakdown(for: applicant, job: job)
        }
    }
    
    // MARK: - Employer actions
    
    func scheduleInterview(recordID: UUID, date: Date, location: String, message: String) {
        guard let index = applications.firstIndex(where: { $0.id == recordID }),
              applications[index].status == .toReview else { return }
        interviews.append(Interview(applicantID: recordID, date: date, location: location, message: message))
        applications[index].status = .interview
        save()
    }
    
    func hire(recordID: UUID) -> HireResult {
        guard let index = applications.firstIndex(where: { $0.id == recordID }) else { return .notFound }
        guard applications[index].status == .interview else { return .notInInterview }
        guard let job = job(withID: applications[index].jobID) else { return .notFound }
        if count(forJob: job.jobID, status: .hired) >= job.maxHire {
            return .jobFull(maxHire: job.maxHire)
        }
        applications[index].status = .hired
        save()
        return .hired
    }
    
    func remove(recordID: UUID) {
        guard let index = applications.firstIndex(where: { $0.id == recordID }) else { return }
        applications[index].isRemoved = true
        interviews.removeAll { $0.applicantID == recordID }
        save()
    }
}
