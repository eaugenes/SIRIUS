//
//  EmpNavigationTab.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/2/26.
//

import SwiftUI

enum EmpNavigationTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case jobs = "Jobs"
    case applicants = "Applicants"
    case profile = "Profile"

    var id: String {
        self.rawValue
    }

    var iconTypes: String {
        switch self {
            case .home: return "house"
            case .jobs: return "briefcase"
            case .applicants: return "person.2"
            case .profile: return "person"
        }
    }
}
