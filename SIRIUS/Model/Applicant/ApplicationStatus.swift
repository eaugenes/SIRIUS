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
    case withdrawn = "Withdrawn"        // shown under "All" only (no tab of its own)
    
    var id: String { self.rawValue }
    
    // Tabs of the My Applications segmented control
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
    
    // Details for the application screen
    var job: Job? = nil
    var profile: MatchProfile? = nil
    var breakdown: MatchBreakdown? = nil
    var interview: Interview? = nil
    var rejectionReason: String = ""
    
    // Hired or already closed applications can't be withdrawn
    var canWithdraw: Bool { status == .applied || status == .interview }
}
