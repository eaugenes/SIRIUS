//
//  AgeRule.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/16/26.
//

import Foundation

enum AgeRule {
    static let minimumAge = 18
    static let errorMessage = "You must be at least \(minimumAge) years old to create an account."

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func latestBirthDate(now: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .year, value: -minimumAge, to: now) ?? now
    }

    static func isOldEnough(_ birthDate: String, now: Date = Date()) -> Bool {
        guard let date = formatter.date(from: birthDate.trimmingCharacters(in: .whitespacesAndNewlines)) else { return false }
        return Calendar.current.startOfDay(for: date) <= Calendar.current.startOfDay(for: latestBirthDate(now: now))
    }
}
