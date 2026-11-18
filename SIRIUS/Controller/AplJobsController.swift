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

struct MatchSummaryRow: Identifiable {
    let title: String
    let score: Int
    let outOf: Int

    var id: String { title }
}

struct MatchSummary {
    let rows: [MatchSummaryRow]
    let gap: String?
}

final class AplJobsController: ObservableObject {

    @Published var searchText = ""
    @Published var pendingJobID: String?
    @Published var returnTab: AplNavigationTab?

    private let info: AplInfoController
    private let board: JobBoard
    private var cancellables = Set<AnyCancellable>()

    init(info: AplInfoController, board: JobBoard = .shared) {
        self.info = info
        self.board = board
        board.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        info.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

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

    var matchedListings: [AplJobListing] {
        allListings.filter { $0.breakdown.isEligible }
    }

    var averageMatch: Int {
        let matched = matchedListings
        guard !matched.isEmpty else { return 0 }
        let total = matched.reduce(0) { $0 + $1.percentage }
        return Int((Double(total) / Double(matched.count)).rounded())
    }

    var matchSummary: MatchSummary? {
        let matched = matchedListings
        guard !matched.isEmpty else { return nil }
        let count = matched.count

        func average(_ value: (MatchBreakdown) -> Int) -> Int {
            Int((Double(matched.reduce(0) { $0 + value($1.breakdown) }) / Double(count)).rounded())
        }

        func shortfall(_ value: (MatchBreakdown) -> Int, outOf: Double) -> Int {
            matched.reduce(0) { $0 + max(0, Int(outOf) - value($1.breakdown)) }
        }

        let rows = [
            MatchSummaryRow(title: "Program", score: average { $0.program }, outOf: Int(MatchRules.programPoints)),
            MatchSummaryRow(title: "Experience", score: average { $0.experience }, outOf: Int(MatchRules.experiencePoints)),
            MatchSummaryRow(title: "Languages", score: average { $0.languages }, outOf: Int(MatchRules.languagePoints)),
            MatchSummaryRow(title: "Work setup", score: average { $0.workSetup }, outOf: Int(MatchRules.workSetupPoints))
        ]

        let losses: [(title: String, loss: Int)] = [
            ("Languages", shortfall({ $0.languages }, outOf: MatchRules.languagePoints)),
            ("Experience", shortfall({ $0.experience }, outOf: MatchRules.experiencePoints)),
            ("Program", shortfall({ $0.program }, outOf: MatchRules.programPoints)),
            ("Work setup", shortfall({ $0.workSetup }, outOf: MatchRules.workSetupPoints))
        ]

        var gap: String?
        if let worst = losses.max(by: { $0.loss < $1.loss }), worst.loss > 0 {
            switch worst.title {
            case "Languages":
                var missed: [String: Int] = [:]
                for listing in matched {
                    for language in listing.breakdown.missingLanguages { missed[language, default: 0] += 1 }
                }
                let names = missed
                    .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
                    .prefix(2)
                    .map { "\($0.key) (\($0.value)/\(count) Jobs)" }
                    .joined(separator: ", ")
                if !names.isEmpty { gap = "Languages | \(names)" }
            case "Experience":
                let jobs = matched.filter { $0.breakdown.experience < Int(MatchRules.experiencePoints) }.count
                gap = "Experience | Below the required years (\(jobs)/\(count) Jobs)"
            case "Program":
                let jobs = matched.filter { $0.breakdown.program < Int(MatchRules.programPoints) }.count
                gap = "Program | Not in the accepted list (\(jobs)/\(count) Jobs)"
            default:
                let jobs = matched.filter { $0.breakdown.workSetup < Int(MatchRules.workSetupPoints) }.count
                gap = "Work setup | Not an exact match (\(jobs)/\(count) Jobs)"
            }
        }

        return MatchSummary(rows: rows, gap: gap)
    }

    var topListing: AplJobListing? { allListings.first { $0.breakdown.isEligible } }

    var pendingCount: Int { board.pendingQualifiedJobs(for: info.applicant).count }

    var nextBatchCount: Int { min(pendingCount, JobBoard.applyBatchSize) }

    @MainActor
    @discardableResult
    func applyToMore() async -> AutoApplyOutcome {
        let outcome = await board.autoApply(applicant: info.applicant)
        if !outcome.applied.isEmpty { await InboxController.shared.reload() }
        return outcome
    }
}
