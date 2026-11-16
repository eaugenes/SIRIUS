//
//  InterviewReminders.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/10/26.
//

import Foundation
import UserNotifications

enum InterviewReminders {

    private static let prefix = "interview-"
    private static let leadTime: TimeInterval = 60 * 60

    private struct Reminder: Sendable {
        let id: String
        let fireDate: Date
        let body: String
    }

    static func sync(_ applications: [JobApplication]) {
        let center = UNUserNotificationCenter.current()
        let now = Date()

        let reminders: [Reminder] = applications.compactMap { app in
            guard app.status == .interview, let interview = app.interview else { return nil }
            let fire = interview.date.addingTimeInterval(-leadTime)
            guard fire > now else { return nil }
            let time = interview.date.formatted(date: .omitted, time: .shortened)
            return Reminder(
                id: prefix + app.id.uuidString,
                fireDate: fire,
                body: "\(app.role) at \(app.company) \u{00B7} \(time) \u{00B7} \(interview.location)"
            )
        }

        let wantedIDs = Set(reminders.map(\.id))
        center.getPendingNotificationRequests { pending in
            let stale = pending.map(\.identifier).filter { $0.hasPrefix(prefix) && !wantedIDs.contains($0) }
            if !stale.isEmpty { center.removePendingNotificationRequests(withIdentifiers: stale) }
        }

        guard !reminders.isEmpty else { return }
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            for reminder in reminders {
                let content = UNMutableNotificationContent()
                content.title = "Interview in 1 hour"
                content.body = reminder.body
                content.sound = .default
                let parts = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second], from: reminder.fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
                center.add(UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger))
            }
        }
    }

    static func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { pending in
            let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}
