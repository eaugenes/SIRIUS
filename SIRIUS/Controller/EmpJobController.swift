//
//  EmpJobController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/6/26.
//

import Foundation
import Combine

// Temporary in-memory job storage for the employer side.
final class EmpJobController: ObservableObject {
    
    @Published var jobs: [Job]
    @Published var selectedTab: JobListTab = .active
    @Published var postError: String?
    
    init(jobs: [Job] = EmpJobController.sampleJobs) {
        self.jobs = jobs
    }
    
    // Jobs for the selected Active / Inactive tab
    var filteredJobs: [Job] {
        switch selectedTab {
        case .active: return jobs.filter { $0.isActive }
        case .inactive: return jobs.filter { !$0.isActive }
        }
    }
    
    // MARK: - Job Posting form
    
    // Validates the raw form input from the Job Posting screen, then posts the job.
    // Returns true when the job was created (the view can then close the form).
    func submitJob(
        companyID: String,
        position: String,
        description: String,
        program: String,
        yearsOfExperience: Int,
        coreLanguages: String,
        workSetup: WorkSetup,
        preferredLocation: String,
        maxHireText: String
    ) -> Bool {
        let trimmedPosition = position.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMaxHire = maxHireText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedPosition.isEmpty {
            postError = "Please enter the job position."
            return false
        }
        if program.isEmpty {
            postError = "Please select a program."
            return false
        }
        guard let maxHire = Int(trimmedMaxHire), maxHire > 0 else {
            postError = "Maximum hire must be a number greater than 0."
            return false
        }
        
        postJob(
            companyID: companyID,
            position: trimmedPosition,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            program: program,
            yearsOfExperience: yearsOfExperience,
            coreLanguages: coreLanguages,
            workSetup: workSetup,
            preferredLocation: preferredLocation.trimmingCharacters(in: .whitespacesAndNewlines),
            maxHire: maxHire
        )
        postError = nil
        return true
    }
    
    // MARK: - CRUD
    
    // Creates a temporary Job and adds it to the list (newest first).
    func postJob(
        companyID: String,
        position: String,
        description: String,
        program: String,
        yearsOfExperience: Int,
        coreLanguages: String,
        workSetup: WorkSetup,
        preferredLocation: String,
        maxHire: Int
    ) {
        let languages = coreLanguages
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let job = Job(
            jobID: UUID().uuidString,
            companyID: companyID,
            jobPos: position.trimmingCharacters(in: .whitespacesAndNewlines),
            jobDesc: description,
            requiredLoc: preferredLocation,
            requiredEduc: program,
            requiredYrExp: Double(yearsOfExperience),
            requiredLang: languages,
            workSetup: workSetup,
            maxHire: maxHire,
            applicantCount: 0,
            datePosted: Date(),
            isActive: true
        )
        
        jobs.insert(job, at: 0)
        selectedTab = .active
    }
    
    // Moves a job between Active and Inactive.
    func toggleStatus(of job: Job) {
        guard let index = jobs.firstIndex(where: { $0.jobID == job.jobID }) else { return }
        jobs[index].isActive.toggle()
    }
    
    func deleteJob(_ job: Job) {
        jobs.removeAll { $0.jobID == job.jobID }
    }
    
    // MARK: - Sample data (matches the Figma "Manage Jobs" screens)
    
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
                    requiredEduc: "BS Computer Science",
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
