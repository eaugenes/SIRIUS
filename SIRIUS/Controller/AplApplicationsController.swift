//
//  ApplicationsController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/15/26.
//

import Foundation
import Combine

// The applicant's applications. They are created automatically by the JobBoard
// when the applicant matches a job at 60% or more.
class AplApplicationsController: ObservableObject {
    @Published var selectedStatus: ApplicationStatus = .all
    @Published private(set) var allApplications: [JobApplication] = []
    
    private let applicantID: UUID?
    private var cancellables = Set<AnyCancellable>()
    
    init(applicantID: UUID? = nil, board: JobBoard = .shared) {
        self.applicantID = applicantID
        allApplications = AplApplicationsController.makeApplications(
            jobs: board.jobs, records: board.applications, applicantID: applicantID
        )
        board.$jobs
            .combineLatest(board.$applications)
            .sink { [weak self] jobs, records in
                guard let self else { return }
                self.allApplications = AplApplicationsController.makeApplications(
                    jobs: jobs, records: records, applicantID: self.applicantID
                )
            }
            .store(in: &cancellables)
    }
    
    static func status(for record: ApplicationRecord) -> ApplicationStatus {
        if record.isRemoved { return .rejected }
        switch record.status {
        case .toReview: return .applied
        case .interview: return .interview
        case .hired: return .accepted
        }
    }
    
    private static func makeApplications(jobs: [Job], records: [ApplicationRecord], applicantID: UUID?) -> [JobApplication] {
        guard let applicantID else { return [] }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        
        return records
            .filter { $0.applicantID == applicantID }
            .sorted { $0.dateApplied > $1.dateApplied }
            .compactMap { record in
                guard let job = jobs.first(where: { $0.jobID == record.jobID }) else { return nil }
                return JobApplication(
                    id: record.id,
                    role: job.jobPos,
                    company: job.companyName.isEmpty ? "Company" : job.companyName,
                    dateApplied: formatter.string(from: record.dateApplied),
                    status: status(for: record),
                    jobID: job.jobID,
                    matchPercentage: record.percentage
                )
            }
    }
    
    var filteredApplications: [JobApplication] {
        if selectedStatus == .all {
            return allApplications
        } else {
            return allApplications.filter { $0.status == selectedStatus }
        }
    }
    
    // Counts for the Application Status card on Home
    func count(of status: ApplicationStatus) -> Int {
        allApplications.filter { $0.status == status }.count
    }
}
