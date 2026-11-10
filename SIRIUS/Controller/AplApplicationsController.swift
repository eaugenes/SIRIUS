//
//  ApplicationsController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/15/26.
//

import Foundation
import Combine

// The applicant's applications. They are created when the applicant applies
// (the first batch at sign up, then "Apply to 10 more" on the Jobs tab).
class AplApplicationsController: ObservableObject {
    @Published var selectedStatus: ApplicationStatus = .all
    @Published private(set) var allApplications: [JobApplication] = []
    // Interviews the applicant has already opened (recordID -> what they saw), kept on this phone
    @Published private(set) var seenInterviews: [String: String] = [:]
    
    private let applicantID: UUID?
    private let board: JobBoard
    private var cancellables = Set<AnyCancellable>()
    
    init(applicantID: UUID? = nil, board: JobBoard = .shared) {
        self.applicantID = applicantID
        self.board = board
        seenInterviews = UserDefaults.standard.dictionary(forKey: Self.seenKey(applicantID)) as? [String: String] ?? [:]
        allApplications = AplApplicationsController.makeApplications(
            jobs: board.jobs, records: board.applications, applicantID: applicantID, interviews: board.interviews
        )
        board.$jobs
            .combineLatest(board.$applications, board.$interviews)
            .sink { [weak self] jobs, records, interviews in
                guard let self else { return }
                self.allApplications = AplApplicationsController.makeApplications(
                    jobs: jobs, records: records, applicantID: self.applicantID, interviews: interviews
                )
            }
            .store(in: &cancellables)
        
        // Keep the 1-hour reminders in step with the interviews (after the data has really loaded)
        $allApplications
            .combineLatest(board.$didLoad)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { applications, didLoad in
                if didLoad { InterviewReminders.sync(applications) }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - "New interview" badge
    
    private static func seenKey(_ id: UUID?) -> String { "seenInterviews.\(id?.uuidString ?? "none")" }
    
    // Changes when the employer sends or reschedules (date, place or message)
    private static func signature(_ interview: Interview) -> String {
        "\(Int(interview.date.timeIntervalSince1970))|\(interview.location)|\(interview.message)"
    }
    
    func hasNewInterview(_ application: JobApplication) -> Bool {
        guard application.status == .interview, let interview = application.interview else { return false }
        return seenInterviews[application.id.uuidString] != Self.signature(interview)
    }
    
    var newInterviewCount: Int { allApplications.filter(hasNewInterview).count }
    
    func markInterviewSeen(_ application: JobApplication) {
        guard application.status == .interview, let interview = application.interview else { return }
        seenInterviews[application.id.uuidString] = Self.signature(interview)
        UserDefaults.standard.set(seenInterviews, forKey: Self.seenKey(applicantID))
    }
    
    // MARK: - Applications
    
    static func status(for record: ApplicationRecord) -> ApplicationStatus {
        if record.isWithdrawn { return .withdrawn }
        if record.isRemoved { return .rejected }
        switch record.status {
        case .toReview: return .applied
        case .interview: return .interview
        case .hired: return .accepted
        }
    }
    
    private static func makeApplications(jobs: [Job], records: [ApplicationRecord], applicantID: UUID?, interviews: [Interview]) -> [JobApplication] {
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
                    matchPercentage: record.percentage,
                    job: job,
                    profile: record.matchProfile,
                    breakdown: record.breakdown,
                    interview: interviews.last { $0.applicantID == record.id },
                    rejectionReason: record.rejectionReason
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
    
    // The applicant withdraws an application (not possible once hired)
    @discardableResult
    func withdraw(_ application: JobApplication) -> Bool {
        board.withdraw(recordID: application.id)
    }
    
    // Counts for the Application Status card on Home
    func count(of status: ApplicationStatus) -> Int {
        allApplications.filter { $0.status == status }.count
    }
}
