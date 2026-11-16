//
//  ProfileLink.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/16/26.
//

import Foundation
import SwiftUI

enum ProfileLink {

    enum Kind {
        case github
        case linkedin

        var label: String {
            switch self {
            case .github: return "GitHub"
            case .linkedin: return "LinkedIn"
            }
        }

        var domains: [String] {
            switch self {
            case .github: return ["github.com"]
            case .linkedin: return ["linkedin.com"]
            }
        }

        var placeholder: String {
            switch self {
            case .github: return "e.g., github.com/username"
            case .linkedin: return "e.g., linkedin.com/in/username"
            }
        }
    }

    static let maxLength = 200

    static func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalized(_ text: String) -> String {
        let value = trimmed(text)
        guard !value.isEmpty else { return "" }
        let lower = value.lowercased()
        if lower.hasPrefix("http://") || lower.hasPrefix("https://") { return value }
        return "https://" + value
    }

    static func isValid(_ text: String, kind: Kind) -> Bool {
        let value = trimmed(text)
        if value.isEmpty { return true }
        guard value.count <= maxLength, !value.contains(" ") else { return false }
        guard let url = URL(string: normalized(value)), let host = url.host?.lowercased() else { return false }
        let matchesDomain = kind.domains.contains { host == $0 || host.hasSuffix("." + $0) }
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return matchesDomain && !path.isEmpty
    }

    static func errorMessage(for kind: Kind) -> String {
        "Enter a valid \(kind.label) link, e.g., \(kind.placeholder.replacingOccurrences(of: "e.g., ", with: ""))."
    }

    static func url(from text: String) -> URL? {
        let value = normalized(text)
        return value.isEmpty ? nil : URL(string: value)
    }
}
