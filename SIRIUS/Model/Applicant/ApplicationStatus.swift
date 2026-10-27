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
    
    var id: String { self.rawValue }
}

struct JobApplication: Identifiable {
    var id = UUID()
    let role: String
    let company: String
    let dateApplied: String
    let status: ApplicationStatus
    var jobID: String = ""
    var matchPercentage: Int = 0
}
