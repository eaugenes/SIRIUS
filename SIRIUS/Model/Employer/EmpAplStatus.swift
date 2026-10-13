//
//  EmployerAplStatus.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/2/26.
//

import Foundation

enum EmpAplStatus: String, CaseIterable, Identifiable {
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
    let id = UUID()
    var name: String
    var degree: String
    var yearsExperience: Int
    var coreLanguages: [String]
    var matchPercentage: Int
    var status: EmpAplStatus = .toReview
    var jobPosition: String = "Junior Software Developer"
}
