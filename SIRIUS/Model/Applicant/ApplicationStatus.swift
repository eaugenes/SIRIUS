//
//  ApplicationStatus.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/15/26.
//

import Foundation

enum ApplicationStatus: String, CaseIterable, Identifiable {
    case all = "All"
    case applied = "Applied"
    case interview = "Interview"
    case accepted = "Accepted"
    case rejected = "Rejected"
    case withdrawn = "Withdrawn"

    var id: String { self.rawValue }

    static let tabs: [ApplicationStatus] = [.all, .applied, .interview, .accepted, .rejected]
}

struct JobApplication: Identifiable {
    var id = UUID()
    let role: String
    let company: String
    let dateApplied: String
    let status: ApplicationStatus
    var jobID: String = ""
    var matchPercentage: Int = 0

    var job: Job? = nil
    var profile: MatchProfile? = nil
    var breakdown: MatchBreakdown? = nil
    var interview: Interview? = nil
    var rejectionReason: String = ""

    var canWithdraw: Bool { status == .applied || status == .interview }
}
