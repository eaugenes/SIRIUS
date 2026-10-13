//
//  EmpAplStatusController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/6/26.
//

import Foundation
import Combine

// Temporary in-memory applicant + interview storage for the employer side.
final class EmpAplStatusController: ObservableObject {
    
    @Published var applicants: [EmpApplicant]
    @Published var interviews: [Interview] = []
    @Published var selectedFilter: EmpApplicantFilter = .all
    @Published var selectedApplicantID: UUID?
    
    // Navigation-related state: non-nil while the Schedule Interview modal is open
    @Published var interviewTarget: EmpApplicant?
    
    init(applicants: [EmpApplicant] = EmpAplStatusController.sampleApplicants) {
        self.applicants = applicants
    }
    
    // MARK: - Filtering / counts
    
    // All applicants for the selected All / To Review / Interview / Hired tab
    var filteredApplicants: [EmpApplicant] {
        filteredApplicants(forPosition: nil)
    }
    
    // Same as above, limited to one job opening when a position is given
    // (used when the employer opens a job from Manage Jobs).
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
        applicants.removeAll { $0.id == applicant.id }
        interviews.removeAll { $0.applicantID == applicant.id }
        if selectedApplicantID == applicant.id {
            selectedApplicantID = nil
        }
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
        
        interviews.append(
            Interview(
                applicantID: target.id,
                date: date,
                location: location.trimmingCharacters(in: .whitespacesAndNewlines),
                message: message.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        )
        
        if let index = applicants.firstIndex(where: { $0.id == target.id }) {
            applicants[index].status = .interview
        }
        
        interviewTarget = nil
        selectedApplicantID = nil
    }
    
    // MARK: - Sample data (matches the Figma "Manage Applicants" screens)
    
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
