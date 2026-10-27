//
//  AplJobsController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation
import Combine

struct AplJobListing: Identifiable {
    let job: Job
    let breakdown: MatchBreakdown
    let hasApplied: Bool
    var profile: MatchProfile = MatchProfile(program: "", yearsExperience: 0, languages: [])
    
    var id: String { job.jobID }
    var percentage: Int { breakdown.total }
}

final class AplJobsController: ObservableObject {
    
    @Published var searchText = ""
    
    private let info: AplInfoController
    private let board: JobBoard
    private var cancellables = Set<AnyCancellable>()
    
    init(info: AplInfoController, board: JobBoard = .shared) {
        self.info = info
        self.board = board
        // Refresh when jobs, applications or the applicant's profile change
        board.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        info.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    // Every active job, best match first
    var allListings: [AplJobListing] {
        let applicant = info.applicant
        return board.activeJobs()
            .map { job in
                AplJobListing(
                    job: job,
                    breakdown: board.breakdown(for: applicant, job: job),
                    hasApplied: board.hasActiveApplication(applicantID: applicant.id, jobID: job.jobID),
                    profile: applicant.matchProfile
                )
            }
            .sorted {
                $0.percentage != $1.percentage ? $0.percentage > $1.percentage : $0.job.datePosted > $1.job.datePosted
            }
    }
    
    var listings: [AplJobListing] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return allListings }
        return allListings.filter {
            $0.job.jobPos.lowercased().contains(query)
            || $0.job.companyName.lowercased().contains(query)
            || $0.job.requiredLoc.lowercased().contains(query)
        }
    }
    
    // Jobs at or above the 60% auto-apply threshold
    var matchedListings: [AplJobListing] {
        allListings.filter { $0.breakdown.isEligible }
    }
    
    var averageMatch: Int {
        let matched = matchedListings
        guard !matched.isEmpty else { return 0 }
        let total = matched.reduce(0) { $0 + $1.percentage }
        return Int((Double(total) / Double(matched.count)).rounded())
    }
    
    var topListing: AplJobListing? { allListings.first { $0.breakdown.isEligible } }
}
