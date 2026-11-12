//
//  Interview.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/2/26.
//

import Foundation

struct Interview: Identifiable {
    let id = UUID()
    var applicantID: UUID           // the id of the application record the interview belongs to
    var date: Date
    var location: String
    var message: String
}

enum EmpInterviewState: Equatable {
    case upcoming               // the interview time has not come yet
    case awaitingDecision       // the interview time passed and the applicant is still in the Interview stage
    case hired                  // the applicant was hired after the interview
    
    var label: String {
        switch self {
        case .upcoming: return "Upcoming"
        case .awaitingDecision: return "Awaiting decision"
        case .hired: return "Hired"
        }
    }
}

// Tabs of the Interviews page
enum EmpInterviewFilter: String, CaseIterable, Identifiable {
    case upcoming = "Upcoming"
    case awaiting = "Awaiting"
    case hired = "Hired"
    
    var id: String { rawValue }
    
    var state: EmpInterviewState {
        switch self {
        case .upcoming: return .upcoming
        case .awaiting: return .awaitingDecision
        case .hired: return .hired
        }
    }
}

// An interview together with the applicant it belongs to
struct EmpInterviewItem: Identifiable {
    let applicant: EmpApplicant
    let interview: Interview
    let state: EmpInterviewState
    
    var id: UUID { applicant.id }
}
