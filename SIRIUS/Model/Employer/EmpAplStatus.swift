//
//  EmployerAplStatus.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/2/26.
//

import Foundation

enum EmpAplStatus: String, CaseIterable, Identifiable, Codable {
    case toReview = "To Review"
    case interview = "Interview"
    case hired = "Hired"
    
    var id: String { self.rawValue }
}

enum EmpApplicantFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case toReview = "To Review"
    case interview = "Interview"
    case hired = "Hired"
    
    var id: String { self.rawValue }
    
    
    var status: EmpAplStatus? {
        switch self {
        case .all: return nil
        case .toReview: return .toReview
        case .interview: return .interview
        case .hired: return .hired
        }
    }
}


struct EmpApplicant: Identifiable, Equatable {
    var id = UUID()                 // same id as the stored application record
    var name: String
    var degree: String
    var yearsExperience: Double
    var coreLanguages: [String]
    var matchPercentage: Int
    var status: EmpAplStatus = .toReview
    var jobPosition: String = "Junior Software Developer"
    var jobID: String = ""          // stable id of the job this applicant applied to
    var breakdown: MatchBreakdown? = nil
    var jobMinYears: Double = 0
    var jobRequiredLanguages: [String] = []
    
    // Whole numbers read "2 years", partial ones "1.5 years"
    var experienceText: String {
        let years = yearsExperience
        let number = years == years.rounded() ? String(Int(years)) : String(format: "%.1f", years)
        return years == 1 ? "1 year work experience" : "\(number) years work experience"
    }
}
