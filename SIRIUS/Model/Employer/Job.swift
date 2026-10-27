//
//  Job.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import Foundation

enum WorkSetup: String, CaseIterable, Identifiable, Codable {
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

struct Job: Identifiable, Hashable, Codable {
    var jobID: String
    var companyID: String
    var jobPos: String
    var jobDesc: String
    var requiredLoc: String
    var requiredProgram: String
    var requiredYrExp: Double
    var requiredLang: [String]
    
    // Employer-side fields (defaults keep older call sites compiling)
    var workSetup: WorkSetup = .onSite
    var maxHire: Int = 1
    var applicantCount: Int = 0
    var datePosted: Date = Date()
    var isActive: Bool = true
    var companyName: String = ""
    var isFilled: Bool = false          // closed automatically because maxHire was reached
    var salary: Int = 0                 // monthly salary in pesos (whole number)
    
    var id: String { jobID }
    
    // "₱25,000" (empty when no salary was set)
    var salaryText: String {
        salary > 0 ? Job.pesoText(salary) : ""
    }
    
    static func pesoText(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return "\u{20B1}" + (formatter.string(from: NSNumber(value: amount)) ?? String(amount))
    }
    
    var matchRequirements: MatchRequirements {
        MatchRequirements(program: requiredProgram, minYearsExperience: requiredYrExp, languages: requiredLang, location: requiredLoc)
    }
}
