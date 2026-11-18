//
//  Interview.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/2/26.
//

import Foundation

struct Interview: Identifiable, Codable {
    var id = UUID()
    var applicantID: UUID
    var date: Date
    var location: String
    var message: String
}

enum EmpInterviewState: Equatable {
    case upcoming
    case awaitingDecision
    case hired

    var label: String {
        switch self {
        case .upcoming: return "Upcoming"
        case .awaitingDecision: return "Awaiting"
        case .hired: return "Hired"
        }
    }
}

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

struct EmpInterviewItem: Identifiable {
    let applicant: EmpApplicant
    let interview: Interview
    let state: EmpInterviewState

    var id: UUID { applicant.id }
}
