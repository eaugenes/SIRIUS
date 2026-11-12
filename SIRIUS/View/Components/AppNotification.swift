//
//  AppNotification.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import Foundation

struct AppNotification: Identifiable, Equatable {
    let id: UUID
    let kind: String            // "auto_applied", "new_applicant", "interview"
    let title: String
    let body: String
    var isRead: Bool
    let createdAt: Date
    
    var icon: String {
        switch kind {
        case "auto_applied": return "paperplane.fill"
        case "new_applicant": return "person.badge.plus"
        case "interview": return "calendar"
        default: return "bell.fill"
        }
    }
    
    // "5 min ago", "Yesterday" ...
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
