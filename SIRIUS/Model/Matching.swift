//
//  Matching.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation

enum MatchRules {
    static let greenMinimum = 80
    static let orangeMinimum = 60
    static let autoApplyThreshold = greenMinimum

    static let programPoints = 20.0
    static let experiencePoints = 20.0
    static let languagePoints = 50.0
    static let workSetupPoints = 10.0
}

struct MatchProfile: Equatable {
    var program: String
    var yearsExperience: Double
    var languages: [String]
    var location: String = ""
    var workSetup: String = ""
}

struct MatchRequirements: Equatable {
    var program: String
    var minYearsExperience: Double
    var languages: [String]
    var location: String = ""
    var workSetup: String = ""
}

struct MatchBreakdown: Equatable, Codable {
    var program: Int
    var experience: Int
    var languages: Int
    var workSetup: Int
    var matchedLanguages: [String]
    var missingLanguages: [String]
    var total: Int
    var locationMatches: Bool? = nil

    var isEligible: Bool { total >= MatchRules.autoApplyThreshold }
    var tier: MatchTier { MatchTier(percentage: total) }
}

enum MatchTier: Equatable {
    case high
    case medium
    case low

    init(percentage: Int) {
        if percentage >= MatchRules.greenMinimum {
            self = .high
        } else if percentage >= MatchRules.orangeMinimum {
            self = .medium
        } else {
            self = .low
        }
    }

    static func fillFraction(for percentage: Int) -> Double {
        if percentage >= 100 { return 1.0 }
        if percentage >= MatchRules.greenMinimum { return 2.0 / 3.0 }
        if percentage >= MatchRules.orangeMinimum { return 1.0 / 3.0 }
        return 0
    }
}

enum Matching {

    static func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func evaluate(_ profile: MatchProfile, against job: MatchRequirements) -> MatchBreakdown {
        let acceptedPrograms = parsePrograms(job.program).map(normalized)
        let applicantProgram = normalized(ProgramCatalog.complete(profile.program))
        let programScore: Double =
            (acceptedPrograms.isEmpty || acceptedPrograms.contains(applicantProgram))
            ? MatchRules.programPoints : 0

        let experienceScore: Double
        if job.minYearsExperience <= 0 {
            experienceScore = MatchRules.experiencePoints
        } else {
            let ratio = min(1.0, max(0, profile.yearsExperience) / job.minYearsExperience)
            experienceScore = MatchRules.experiencePoints * ratio
        }

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

        let workSetupScore = MatchRules.workSetupPoints * workSetupFactor(applicant: profile.workSetup, job: job.workSetup)

        let program = Int(programScore.rounded(.toNearestOrAwayFromZero))
        let experience = Int(experienceScore.rounded(.toNearestOrAwayFromZero))
        let languages = Int(languageScore.rounded(.toNearestOrAwayFromZero))
        let workSetup = Int(workSetupScore.rounded(.toNearestOrAwayFromZero))

        return MatchBreakdown(
            program: program,
            experience: experience,
            languages: languages,
            workSetup: workSetup,
            matchedLanguages: matched,
            missingLanguages: missing,
            total: min(100, max(0, program + experience + languages + workSetup)),
            locationMatches: locationMatches(applicant: profile.location, job: job.location)
        )
    }

    static func workSetupFactor(applicant: String, job: String) -> Double {
        let wanted = normalized(job)
        guard !wanted.isEmpty else { return 1 }
        let have = normalized(applicant)
        guard !have.isEmpty else { return 0 }
        if have == wanted { return 1 }
        let hybrid = normalized(WorkSetup.hybrid.rawValue)
        if have == hybrid || wanted == hybrid { return 0.5 }
        return 0
    }

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

    static func locationMatches(applicant: String, job: String) -> Bool? {
        let wanted = normalized(job)
        guard !wanted.isEmpty else { return nil }
        let have = normalized(applicant)
        guard !have.isEmpty else { return false }
        return have == wanted || have.contains(wanted) || wanted.contains(have)
    }

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

        let jobSetup = job.workSetup.isEmpty ? "any" : job.workSetup
        let applicantSetup = profile.workSetup.isEmpty ? "none chosen" : profile.workSetup
        let workSetupDetail: String
        if breakdown.workSetup == Int(MatchRules.workSetupPoints) {
            workSetupDetail = "The job is \(jobSetup); your preference (\(applicantSetup)) fits."
        } else if breakdown.workSetup > 0 {
            workSetupDetail = "The job is \(jobSetup); you prefer \(applicantSetup). Hybrid counts as a partial fit."
        } else {
            workSetupDetail = "The job is \(jobSetup); you prefer \(applicantSetup)."
        }

        return [
            MatchExplanationLine(title: "Program", score: breakdown.program, outOf: Int(MatchRules.programPoints), detail: programDetail),
            MatchExplanationLine(title: "Work experience", score: breakdown.experience, outOf: Int(MatchRules.experiencePoints), detail: experienceDetail),
            MatchExplanationLine(title: "Programming languages", score: breakdown.languages, outOf: Int(MatchRules.languagePoints), detail: languageDetail),
            MatchExplanationLine(title: "Work setup", score: breakdown.workSetup, outOf: Int(MatchRules.workSetupPoints), detail: workSetupDetail)
        ]
    }

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
