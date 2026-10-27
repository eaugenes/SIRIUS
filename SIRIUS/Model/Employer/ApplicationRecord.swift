//
//  ApplicationRecord.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation

struct ApplicationRecord: Identifiable, Codable, Equatable {
    var id = UUID()
    var jobID: String
    var applicantID: UUID
    var applicantName: String
    var degree: String
    var yearsExperience: Double
    var languages: [String]
    var breakdown: MatchBreakdown
    var status: EmpAplStatus = .toReview
    var location: String = ""
    var resumeFileName: String = ""
    var rejectionReason: String = ""        // shown to the applicant when the employer rejects
    var isWithdrawn: Bool = false           // the applicant withdrew; kept so they are not auto-applied again
    var isRemoved: Bool = false             // removed by the employer; kept so the applicant is not auto-applied again
    var dateApplied: Date = Date()
    var percentage: Int { breakdown.total }
    var matchProfile: MatchProfile {
        MatchProfile(program: degree, yearsExperience: yearsExperience, languages: languages, location: location)
    }
}

enum HireResult: Equatable {
    case hired
    case notInInterview
    case jobFull(maxHire: Int)
    case notFound
    
    var message: String? {
        switch self {
        case .hired: return nil
        case .notInInterview: return "Only applicants in the Interview stage can be hired."
        case .jobFull(let maxHire): return "This job already has its maximum of \(maxHire) hire(s)."
        case .notFound: return "That applicant could not be found."
        }
    }
}
