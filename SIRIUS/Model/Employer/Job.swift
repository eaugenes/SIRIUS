//
//  Job.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import Foundation

enum WorkSetup: String, CaseIterable, Identifiable {
    case onSite = "On-site"
    case remote = "Remote"
    case hybrid = "Hybrid"
    
    var id: String { self.rawValue }
}

enum JobListTab: String, CaseIterable, Identifiable {
    case active = "Active"
    case inactive = "Inactive"
    
    var id: String { self.rawValue }
}

struct Job: Identifiable, Hashable{
    var jobID: String
    var companyID: String
    var jobPos: String
    var jobDesc: String
    var requiredLoc: String
    var requiredEduc: String
    var requiredYrExp: Double
    var requiredLang: [String]
    
    // Employer-side fields (defaults keep older call sites compiling)
    var workSetup: WorkSetup = .onSite
    var maxHire: Int = 1
    var applicantCount: Int = 0
    var datePosted: Date = Date()
    var isActive: Bool = true
    
    var id: String { jobID }
}
