//
//  InterviewReminders.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/10/26.
//


import Foundation
import UserNotifications

// Local reminder 1 hour before each interview. It lives on the applicant's phone, so it can only be
// scheduled after the app has loaded the interview. It is not a push notification.
enum InterviewReminders {
    
    private static let prefix = "interview-"
    private static let leadTime: TimeInterval = 60 * 60          // 1 hour before
    
    private struct Reminder: Sendable {
        let id: String
        let fireDate: Date
        let body: String
    }
    
    // Makes the scheduled reminders match the applications: adds / moves reminders for upcoming
    // interviews and removes the ones whose interview was withdrawn, rejected or changed.
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
        // The system asks for permission once, the first time there is an interview to remind about
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
                // Same identifier replaces the old reminder, so a reschedule moves it
                center.add(UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger))
            }
        }
    }
    
    // Called on log out so the next user doesn't get the previous user's reminders
    static func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { pending in
            let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}