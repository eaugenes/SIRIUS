//
//  EmpAplStatusController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/6/26.
//

import Foundation
import Combine

// Employer applicant lists. Applicants come from the shared JobBoard (automatic applications
// from matched applicants), grouped by stable jobID. Passing `applicants:` keeps everything
// in memory (previews / tests).
final class EmpAplStatusController: ObservableObject {
    
    @Published var applicants: [EmpApplicant]
    @Published var interviews: [Interview] = []
    @Published var selectedFilter: EmpApplicantFilter = .all
    @Published var selectedApplicantID: UUID?
    @Published var actionError: String?
    
    // Navigation-related state: non-nil while the Schedule Interview modal is open
    @Published var interviewTarget: EmpApplicant?
    
    private let board: JobBoard?
    private let companyID: String?
    private var cancellables = Set<AnyCancellable>()
    
    init(applicants: [EmpApplicant]? = nil, companyID: String? = nil, board: JobBoard = .shared) {
        self.companyID = companyID
        if let applicants {
            self.applicants = applicants
            self.board = nil
        } else {
            self.board = board
            self.applicants = EmpAplStatusController.makeApplicants(jobs: board.jobs, records: board.applications, companyID: companyID)
            self.interviews = board.interviews
            board.$jobs
                .combineLatest(board.$applications)
                .sink { [weak self] jobs, records in
                    guard let self else { return }
                    self.applicants = EmpAplStatusController.makeApplicants(jobs: jobs, records: records, companyID: self.companyID)
                    // Drop selection / modal target if that applicant no longer exists
                    if let id = self.selectedApplicantID, !self.applicants.contains(where: { $0.id == id }) {
                        self.selectedApplicantID = nil
                    }
                    if let target = self.interviewTarget, !self.applicants.contains(where: { $0.id == target.id }) {
                        self.interviewTarget = nil
                    }
                }
                .store(in: &cancellables)
            board.$interviews
                .sink { [weak self] interviews in self?.interviews = interviews }
                .store(in: &cancellables)
        }
    }
    
    // Applications of this company's jobs (removed ones are hidden), tied to their job by jobID
    private static func makeApplicants(jobs: [Job], records: [ApplicationRecord], companyID: String?) -> [EmpApplicant] {
        let companyJobs = jobs.filter { companyID == nil || $0.companyID == companyID }
        var result: [EmpApplicant] = []
        for job in companyJobs {
            for record in records where record.jobID == job.jobID && !record.isRemoved {
                result.append(
                    EmpApplicant(
                        id: record.id,
                        name: record.applicantName,
                        degree: record.degree,
                        yearsExperience: record.yearsExperience,
                        coreLanguages: record.languages,
                        matchPercentage: record.percentage,
                        status: record.status,
                        jobPosition: job.jobPos,
                        jobID: job.jobID,
                        breakdown: record.breakdown,
                        jobMinYears: job.requiredYrExp,
                        jobRequiredLanguages: job.requiredLang
                    )
                )
            }
        }
        // Highest match first; ties are ordered by name so the list never reshuffles
        return result.sorted {
            $0.matchPercentage != $1.matchPercentage ? $0.matchPercentage > $1.matchPercentage : $0.name < $1.name
        }
    }
    
    // MARK: - Filtering / counts
    
    // All applicants for the selected All / To Review / Interview / Hired tab
    var filteredApplicants: [EmpApplicant] {
        filteredApplicants(forPosition: nil)
    }
    
    // Same as above, limited to one job opening when a position is given
    func filteredApplicants(forPosition position: String?) -> [EmpApplicant] {
        var list = applicants
        
        if let position {
            list = list.filter { $0.jobPosition == position }
        }
        if let status = selectedFilter.status {
            list = list.filter { $0.status == status }
        }
        return list
    }
    
    // Limited to one job by its stable id (two jobs may share a title)
    func filteredApplicants(forJobID jobID: String) -> [EmpApplicant] {
        var list = applicants.filter { $0.jobID == jobID }
        if let status = selectedFilter.status {
            list = list.filter { $0.status == status }
        }
        return list
    }
    
    func count(forJobID jobID: String, status: EmpAplStatus? = nil) -> Int {
        applicants.filter { $0.jobID == jobID && (status == nil || $0.status == status) }.count
    }
    
    func totalApplicants(inJobs jobIDs: Set<String>) -> Int {
        applicants.filter { jobIDs.contains($0.jobID) }.count
    }
    
    var totalCount: Int { applicants.count }
    var toReviewCount: Int { applicants.filter { $0.status == .toReview }.count }
    var interviewCount: Int { applicants.filter { $0.status == .interview }.count }
    var hiredCount: Int { applicants.filter { $0.status == .hired }.count }
    
    var averageMatch: Int {
        guard !applicants.isEmpty else { return 0 }
        let total = applicants.reduce(0) { $0 + $1.matchPercentage }
        return Int((Double(total) / Double(applicants.count)).rounded())
    }
    
    // MARK: - Selection
    
    func isSelected(_ applicant: EmpApplicant) -> Bool {
        selectedApplicantID == applicant.id
    }
    
    func toggleSelection(_ applicant: EmpApplicant) {
        selectedApplicantID = isSelected(applicant) ? nil : applicant.id
    }
    
    func clearSelection() {
        selectedApplicantID = nil
    }
    
    // MARK: - Remove
    
    func removeApplicant(_ applicant: EmpApplicant) {
        if let board {
            board.remove(recordID: applicant.id)
        } else {
            applicants.removeAll { $0.id == applicant.id }
            interviews.removeAll { $0.applicantID == applicant.id }
        }
        if selectedApplicantID == applicant.id {
            selectedApplicantID = nil
        }
    }
    
    // MARK: - Hire
    
    // Interview -> Hired, limited by the job's maximum hire.
    func hire(_ applicant: EmpApplicant) {
        if let board {
            actionError = board.hire(recordID: applicant.id).message
        } else if let index = applicants.firstIndex(where: { $0.id == applicant.id }), applicants[index].status == .interview {
            applicants[index].status = .hired
            actionError = nil
        }
        selectedApplicantID = nil
    }
    
    // MARK: - Interview scheduling
    
    func beginScheduling(_ applicant: EmpApplicant) {
        interviewTarget = applicant
    }
    
    func cancelScheduling() {
        interviewTarget = nil
    }
    
    // Saves the interview, moves the applicant to Interview, closes the modal.
    func scheduleInterview(date: Date, location: String, message: String) {
        guard let target = interviewTarget else { return }
        let cleanLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let board {
            board.scheduleInterview(recordID: target.id, date: date, location: cleanLocation, message: cleanMessage)
        } else {
            interviews.append(Interview(applicantID: target.id, date: date, location: cleanLocation, message: cleanMessage))
            if let index = applicants.firstIndex(where: { $0.id == target.id }) {
                applicants[index].status = .interview
            }
        }
        
        interviewTarget = nil
        selectedApplicantID = nil
    }
    
    // MARK: - Sample data (previews only)
    
    private static let languages = ["Python", "JavaScript", "C++"]
    
    static let sampleApplicants: [EmpApplicant] = [
        EmpApplicant(name: "Franck Almareno", degree: "BS Computer Science", yearsExperience: 2, coreLanguages: languages, matchPercentage: 95, status: .toReview),
        EmpApplicant(name: "Debbie Gutierrez", degree: "BS Computer Science", yearsExperience: 2, coreLanguages: languages, matchPercentage: 93, status: .toReview),
        EmpApplicant(name: "Althea Goose", degree: "BS Computer Science", yearsExperience: 2, coreLanguages: languages, matchPercentage: 90, status: .toReview),
        EmpApplicant(name: "Luis Slurpia", degree: "BS Computer Science", yearsExperience: 2, coreLanguages: languages, matchPercentage: 85, status: .interview),
        EmpApplicant(name: "Kyle Buendia", degree: "BS Computer Science", yearsExperience: 2, coreLanguages: languages, matchPercentage: 92, status: .hired),
        EmpApplicant(name: "Mary Gardenia", degree: "BS Computer Science", yearsExperience: 2, coreLanguages: languages, matchPercentage: 88, status: .interview),
        EmpApplicant(name: "Mico Comartin", degree: "BS Computer Science", yearsExperience: 2, coreLanguages: languages, matchPercentage: 90, status: .hired)
    ]
}
