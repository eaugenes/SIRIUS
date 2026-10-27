//
//  Matching.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation

enum MatchRules {
    static let autoApplyThreshold = 60          // minimum % for an automatic application
    static let programPoints = 20.0
    static let experiencePoints = 20.0
    static let languagePoints = 60.0
}

// What the matcher needs to know about an applicant
struct MatchProfile: Equatable {
    var program: String
    var yearsExperience: Double
    var languages: [String]
    var location: String = ""
}

// What the matcher needs to know about a job
struct MatchRequirements: Equatable {
    var program: String
    var minYearsExperience: Double
    var languages: [String]
    var location: String = ""
}

// Per-category result shown on the applicant details / job details screens
struct MatchBreakdown: Equatable, Codable {
    var program: Int                // out of 20
    var experience: Int             // out of 20
    var languages: Int              // out of 60
    var matchedLanguages: [String]
    var missingLanguages: [String]
    var total: Int                  // 0...100
    // Location is shown to the employer / applicant and used as a tie-breaker, but it is NOT part of
    // the 100 points. nil = the job has no preferred location.
    var locationMatches: Bool? = nil
    
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
        // Program: all-or-nothing. The job may list several accepted programs
        // ("BS Computer Science, BS Information Technology" or "... or ..."); any one counts.
        // A job with no required program gives full marks.
        // Short forms are completed first ("BS CS" -> "BS Computer Science").
        let acceptedPrograms = parsePrograms(job.program).map(normalized)
        let applicantProgram = normalized(ProgramCatalog.complete(profile.program))
        let programScore: Double =
            (acceptedPrograms.isEmpty || acceptedPrograms.contains(applicantProgram))
            ? MatchRules.programPoints : 0
        
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
        
        // Each category is rounded once; the total is the sum of the displayed parts,
        // so the breakdown (e.g. 20 + 15 + 40) always adds up to the overall percentage.
        let program = Int(programScore.rounded(.toNearestOrAwayFromZero))
        let experience = Int(experienceScore.rounded(.toNearestOrAwayFromZero))
        let languages = Int(languageScore.rounded(.toNearestOrAwayFromZero))
        
        return MatchBreakdown(
            program: program,
            experience: experience,
            languages: languages,
            matchedLanguages: matched,
            missingLanguages: missing,
            total: min(100, max(0, program + experience + languages)),
            locationMatches: locationMatches(applicant: profile.location, job: job.location)
        )
    }
    
    // Splits "BS CS, BS IT or BS IS" style input into the accepted program names
    static func parsePrograms(_ text: String) -> [String] {
        let unified = text
            .replacingOccurrences(of: ";", with: ",")
            .replacingOccurrences(of: "\n", with: ",")
            .replacingOccurrences(of: " or ", with: ",", options: .caseInsensitive)
        return unified.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { ProgramCatalog.complete($0) }
            .reduce(into: [String]()) { list, name in
                if !list.contains(where: { normalized($0) == normalized(name) }) { list.append(name) }
            }
    }
    
    // nil when the job has no preferred location. Otherwise true when the applicant's location
    // is the same place (case-insensitive; "Lucena" matches "Lucena City").
    static func locationMatches(applicant: String, job: String) -> Bool? {
        let wanted = normalized(job)
        guard !wanted.isEmpty else { return nil }
        let have = normalized(applicant)
        guard !have.isEmpty else { return false }
        return have == wanted || have.contains(wanted) || wanted.contains(have)
    }
    
    // Plain-language lines that explain every part of a score (used on the applicant screens)
    static func explain(_ profile: MatchProfile, against job: MatchRequirements, breakdown: MatchBreakdown) -> [MatchExplanationLine] {
        let programs = parsePrograms(job.program)
        let applicantProgram = profile.program.isEmpty ? "no program" : ProgramCatalog.complete(profile.program)
        let programDetail: String
        if programs.isEmpty {
            programDetail = "Any program is accepted."
        } else if breakdown.program == Int(MatchRules.programPoints) {
            programDetail = "Your program (\(applicantProgram)) is accepted."
        } else {
            programDetail = "Needs \(programs.joined(separator: " or ")); you have \(applicantProgram)."
        }
        
        let years = job.minYearsExperience
        let yearsText = years == years.rounded() ? String(Int(years)) : String(format: "%.1f", years)
        let have = profile.yearsExperience == profile.yearsExperience.rounded()
            ? String(Int(profile.yearsExperience)) : String(format: "%.1f", profile.yearsExperience)
        let experienceDetail = years <= 0
            ? "No minimum experience is required."
            : "Needs \(yearsText) year(s); you have \(have). Points are proportional up to the minimum."
        
        let languageDetail: String
        if breakdown.matchedLanguages.isEmpty && breakdown.missingLanguages.isEmpty {
            languageDetail = "No specific languages are required."
        } else {
            var parts: [String] = []
            if !breakdown.matchedLanguages.isEmpty { parts.append("You know \(breakdown.matchedLanguages.joined(separator: ", "))") }
            if !breakdown.missingLanguages.isEmpty { parts.append("missing \(breakdown.missingLanguages.joined(separator: ", "))") }
            languageDetail = parts.joined(separator: "; ") + "."
        }
        
        return [
            MatchExplanationLine(title: "Program", score: breakdown.program, outOf: 20, detail: programDetail),
            MatchExplanationLine(title: "Work experience", score: breakdown.experience, outOf: 20, detail: experienceDetail),
            MatchExplanationLine(title: "Programming languages", score: breakdown.languages, outOf: 60, detail: languageDetail)
        ]
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

struct MatchExplanationLine: Identifiable, Equatable {
    let title: String
    let score: Int
    let outOf: Int
    let detail: String
    var id: String { title }
}
