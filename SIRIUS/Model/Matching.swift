//
//  Matching.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation

enum MatchRules {
    static let autoApplyThreshold = 60          // minimum % for an automatic application
    static let educationPoints = 20.0
    static let experiencePoints = 20.0
    static let languagePoints = 60.0
}

// What the matcher needs to know about an applicant
struct MatchProfile: Equatable {
    var program: String
    var yearsExperience: Double
    var languages: [String]
}

// What the matcher needs to know about a job
struct MatchRequirements: Equatable {
    var program: String
    var minYearsExperience: Double
    var languages: [String]
}

// Per-category result shown on the applicant details / job details screens
struct MatchBreakdown: Equatable, Codable {
    var education: Int              // out of 20
    var experience: Int             // out of 20
    var languages: Int              // out of 60
    var matchedLanguages: [String]
    var missingLanguages: [String]
    var total: Int                  // 0...100
    
    var isEligible: Bool { total >= MatchRules.autoApplyThreshold }
    var tier: MatchTier { MatchTier(percentage: total) }
}

// Colour band of a percentage: green >= 80, orange 60-79, red < 60
enum MatchTier: Equatable {
    case high           // 80...100
    case medium         // 60...79
    case low            // below 60 (not eligible)
    
    init(percentage: Int) {
        if percentage >= 80 {
            self = .high
        } else if percentage >= MatchRules.autoApplyThreshold {
            self = .medium
        } else {
            self = .low
        }
    }
    
    // Manage Applicants fill level: 100% -> full, 80-99% -> two thirds,
    // 60-79% -> one third, below 60% -> empty (not eligible).
    // This is a visual level only; the real percentage is shown separately.
    static func fillFraction(for percentage: Int) -> Double {
        if percentage >= 100 { return 1.0 }
        if percentage >= 80 { return 2.0 / 3.0 }
        if percentage >= MatchRules.autoApplyThreshold { return 1.0 / 3.0 }
        return 0
    }
}

enum Matching {
    
    static func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    static func evaluate(_ profile: MatchProfile, against job: MatchRequirements) -> MatchBreakdown {
        // Education: all-or-nothing. A job with no required program gives full marks.
        let requiredProgram = normalized(job.program)
        let educationScore: Double =
            (requiredProgram.isEmpty || requiredProgram == normalized(profile.program))
            ? MatchRules.educationPoints : 0
        
        // Experience: proportional, capped at full marks. No minimum gives full marks.
        let experienceScore: Double
        if job.minYearsExperience <= 0 {
            experienceScore = MatchRules.experiencePoints
        } else {
            let ratio = min(1.0, max(0, profile.yearsExperience) / job.minYearsExperience)
            experienceScore = MatchRules.experiencePoints * ratio
        }
        
        // Languages: share of the required languages the applicant knows (case-insensitive, de-duplicated)
        var required: [String] = []
        for language in job.languages {
            let key = normalized(language)
            if !key.isEmpty && !required.contains(where: { normalized($0) == key }) {
                required.append(language.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        let known = Set(profile.languages.map(normalized))
        let matched = required.filter { known.contains(normalized($0)) }
        let missing = required.filter { !known.contains(normalized($0)) }
        let languageScore: Double =
            required.isEmpty
            ? MatchRules.languagePoints
            : MatchRules.languagePoints * Double(matched.count) / Double(required.count)
        
        let total = Int((educationScore + experienceScore + languageScore).rounded(.toNearestOrAwayFromZero))
        
        return MatchBreakdown(
            education: Int(educationScore.rounded(.toNearestOrAwayFromZero)),
            experience: Int(experienceScore.rounded(.toNearestOrAwayFromZero)),
            languages: Int(languageScore.rounded(.toNearestOrAwayFromZero)),
            matchedLanguages: matched,
            missingLanguages: missing,
            total: min(100, max(0, total))
        )
    }
    
    // Splits "Python, C++ ; Swift" style input into clean unique names
    static func parseLanguages(_ text: String) -> [String] {
        var result: [String] = []
        let parts = text.split(whereSeparator: { $0 == "," || $0 == ";" || $0 == "\n" })
        for part in parts {
            let name = part.trimmingCharacters(in: .whitespacesAndNewlines)
            if !name.isEmpty && !result.contains(where: { normalized($0) == normalized(name) }) {
                result.append(name)
            }
        }
        return result
    }
}
