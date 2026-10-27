//
//  EmpJobController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/6/26.
//

import Foundation
import Combine

// Employer job list. Jobs live in the shared JobBoard (saved to disk), so applicants
// see them and are applied automatically. Passing `jobs:` keeps everything in memory
// (previews / tests).
final class EmpJobController: ObservableObject {
    
    @Published var jobs: [Job]
    @Published var selectedTab: JobListTab = .active
    @Published var postError: String?
    @Published var statusError: String?        // e.g. a filled job cannot be reopened
    
    private let board: JobBoard?
    private let auth: AuthController
    private let companyID: String?
    private let companyName: String
    private var cancellables = Set<AnyCancellable>()
    
    init(
        jobs: [Job]? = nil,
        companyID: String? = nil,
        companyName: String = "",
        board: JobBoard = .shared,
        auth: AuthController = .shared
    ) {
        self.companyID = companyID
        self.companyName = companyName
        self.auth = auth
        
        if let jobs {
            self.jobs = jobs
            self.board = nil
        } else {
            self.board = board
            self.jobs = EmpJobController.companyJobs(board.jobs, board.applications, companyID: companyID)
            board.$jobs
                .combineLatest(board.$applications)
                .sink { [weak self] jobs, applications in
                    guard let self else { return }
                    self.jobs = EmpJobController.companyJobs(jobs, applications, companyID: self.companyID)
                }
                .store(in: &cancellables)
        }
    }
    
    // Jobs of this employer's company, with the live applicant count
    private static func companyJobs(_ jobs: [Job], _ applications: [ApplicationRecord], companyID: String?) -> [Job] {
        jobs
            .filter { companyID == nil || $0.companyID == companyID }
            .map { job in
                var copy = job
                copy.applicantCount = applications.filter { $0.jobID == job.jobID && !$0.isRemoved && !$0.isWithdrawn }.count
                return copy
            }
    }
    
    // Jobs for the selected Active / Inactive tab
    var filteredJobs: [Job] {
        switch selectedTab {
        case .active: return jobs.filter { $0.isActive }
        case .inactive: return jobs.filter { !$0.isActive }
        }
    }
    
    var activeJobCount: Int { jobs.filter { $0.isActive }.count }
    
    // MARK: - Job Posting form
    
    // Validates the raw form input from the Job Posting screen, then posts (or updates) the job.
    // Returns true when the job was saved (the view can then close the form).
    func submitJob(
        companyID: String,
        position: String,
        description: String,
        program: String,
        yearsOfExperience: Int,
        coreLanguages: String,
        workSetup: WorkSetup,
        preferredLocation: String,
        maxHireText: String,
        salaryText: String,
        editing existing: Job? = nil
    ) -> Bool {
        let trimmedPosition = position.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMaxHire = maxHireText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedPosition.isEmpty {
            postError = "Please enter the job position."
            return false
        }
        if program.isEmpty {
            postError = "Please select at least one program."
            return false
        }
        if Matching.parseLanguages(coreLanguages).isEmpty {
            postError = "Please enter at least one core language."
            return false
        }
        let trimmedSalary = salaryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSalary.isEmpty,
              trimmedSalary.allSatisfy({ $0.isASCII && $0.isNumber }),
              let salary = Int(trimmedSalary), salary > 0, salary <= 10_000_000 else {
            postError = "Please enter the salary in pesos (numbers only)."
            return false
        }
        guard let maxHire = Int(trimmedMaxHire), maxHire > 0, maxHire <= 1000 else {
            postError = "Maximum hire must be a number between 1 and 1000."
            return false
        }
        if let existing, maxHire < hiredCount(for: existing) {
            postError = "Maximum hire can't be lower than the \(hiredCount(for: existing)) applicant(s) already hired."
            return false
        }
        
        if let existing {
            var updated = existing
            updated.jobPos = trimmedPosition
            updated.jobDesc = description.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.requiredProgram = program
            updated.requiredYrExp = Double(yearsOfExperience)
            updated.requiredLang = Matching.parseLanguages(coreLanguages)
            updated.workSetup = workSetup
            updated.requiredLoc = preferredLocation.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.maxHire = maxHire
            updated.salary = salary
            updateJob(updated)
        } else {
            postJob(
                companyID: companyID,
                position: trimmedPosition,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                program: program,
                yearsOfExperience: yearsOfExperience,
                coreLanguages: coreLanguages,
                workSetup: workSetup,
                preferredLocation: preferredLocation.trimmingCharacters(in: .whitespacesAndNewlines),
                maxHire: maxHire,
                salary: salary
            )
        }
        postError = nil
        return true
    }
    
    // MARK: - CRUD
    
    // Creates a Job (stable jobID) and adds it to the list (newest first).
    func postJob(
        companyID: String,
        position: String,
        description: String,
        program: String,
        yearsOfExperience: Int,
        coreLanguages: String,
        workSetup: WorkSetup,
        preferredLocation: String,
        maxHire: Int,
        salary: Int = 0
    ) {
        let job = Job(
            jobID: UUID().uuidString.lowercased(),     // lowercase, same as the database returns
            companyID: companyID,
            jobPos: position.trimmingCharacters(in: .whitespacesAndNewlines),
            jobDesc: description,
            requiredLoc: preferredLocation,
            requiredProgram: program,
            requiredYrExp: Double(yearsOfExperience),
            requiredLang: Matching.parseLanguages(coreLanguages),
            workSetup: workSetup,
            maxHire: maxHire,
            applicantCount: 0,
            datePosted: Date(),
            isActive: true,
            companyName: companyName,
            salary: salary
        )
        
        if let board {
            board.addJob(job)
        } else {
            jobs.insert(job, at: 0)
        }
        selectedTab = .active
    }
    
    func updateJob(_ job: Job) {
        if let board {
            board.updateJob(job)
        } else if let index = jobs.firstIndex(where: { $0.jobID == job.jobID }) {
            jobs[index] = job
        }
    }
    
    // Moves a job between Active and Inactive.
    func toggleStatus(of job: Job) {
        statusError = nil
        if let board {
            let changed = board.setActive(jobID: job.jobID, isActive: !job.isActive)
            if !changed {
                statusError = "All \(job.maxHire) position(s) are filled. Edit the job and raise the maximum hire to reopen it."
            }
        } else if let index = jobs.firstIndex(where: { $0.jobID == job.jobID }) {
            jobs[index].isActive.toggle()
        }
    }
    
    func deleteJob(_ job: Job) {
        if let board {
            board.deleteJob(jobID: job.jobID)
        } else {
            jobs.removeAll { $0.jobID == job.jobID }
        }
    }
    
    func hiredCount(for job: Job) -> Int {
        board?.count(forJob: job.jobID, status: .hired) ?? 0
    }
    
    // MARK: - Sample data (previews only)
    
    private static let may18: Date = {
        DateComponents(calendar: Calendar.current, year: 2026, month: 5, day: 18).date ?? Date()
    }()
    
    static let sampleJobs: [Job] = {
        var list: [Job] = []
        for index in 0..<15 {
            list.append(
                Job(
                    jobID: "sample-\(index)",
                    companyID: "",
                    jobPos: "Junior Software Developer",
                    jobDesc: "",
                    requiredLoc: "Lucena City",
                    requiredProgram: "BS Computer Science",
                    requiredYrExp: 1,
                    requiredLang: ["Python", "C++"],
                    workSetup: .onSite,
                    maxHire: 3,
                    applicantCount: 42,
                    datePosted: may18,
                    isActive: index < 10          // first 10 Active, last 5 Inactive
                )
            )
        }
        return list
    }()
}
