//
//  AplNavigationTab.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/14/26.
//

import SwiftUI

enum AplNavigationTab: String, CaseIterable, Identifiable{
    case home = "Home"
    case jobs = "Jobs"
    case applications = "Applications"
    case profile = "Account"

    var id: String {
        self.rawValue
    }

    var iconTypes: String {
        switch self {
            case .home: return "house"
            case .jobs: return "magnifyingglass"
            case .applications: return "paperplane"
            case .profile: return "person"
        }
    }
}
