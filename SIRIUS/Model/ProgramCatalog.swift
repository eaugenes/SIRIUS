//
//  ProgramCatalog.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation

// Completes short / informal program names to the official "BS ..." name,
// e.g. "BS CS", "bscs", "CS", "Computer Science" -> "BS Computer Science".
enum ProgramCatalog {
    
    // Official names (must match ProgramsList.programs)
    static let officialNames: [String] = [
        "BS Computer Science",
        "BS Cybersecurity",
        "BS Data Science",
        "BS Entertainment and Multimedia Computing",
        "BS Information Systems",
        "BS Information Technology"
    ]
    
    // Lower-case, letters and digits only (drops spaces, dots, dashes, "&")
    private static func key(_ text: String) -> String {
        String(text.lowercased().filter { $0.isLetter || $0.isNumber })
    }
    
    // Alias key -> official name. Keys are written without the "bs" prefix and are looked up
    // both with and without it ("cs", "bscs", "computerscience", "bscomputerscience", ...).
    private static let aliases: [String: String] = {
        var table: [String: String] = [:]
        func add(_ official: String, _ names: [String]) {
            for name in names { table[key(name)] = official }
        }
        add("BS Computer Science", ["cs", "comp sci", "compsci", "computer science", "computer sciences", "sci comp"])
        add("BS Cybersecurity", ["cys", "cybersec", "cyber sec", "cyber security", "cybersecurity", "cyber"])
        add("BS Data Science", ["ds", "data sci", "datasci", "data science"])
        add("BS Entertainment and Multimedia Computing", ["emc", "entertainment and multimedia computing", "entertainment multimedia computing", "multimedia computing", "multimedia"])
        add("BS Information Systems", ["is", "info systems", "info sys", "information system", "information systems"])
        add("BS Information Technology", ["it", "info tech", "infotech", "information technology"])
        return table
    }()
    
    // Removes "BS", "B.S.", "Bachelor of Science (in)" from the front of the text
    private static func strippedKey(_ text: String) -> String {
        var k = key(text)
        for prefix in ["bachelorofscienceincomputer", "bachelorofscienceinfo", "bachelorofsciencein", "bachelorofscience"] {
            if k.hasPrefix(prefix) {
                // keep the subject word(s) that follow
                k = String(k.dropFirst(prefix.count))
                if prefix.hasSuffix("computer") { k = "computer" + k }
                if prefix.hasSuffix("info") { k = "info" + k }
                break
            }
        }
        if k.hasPrefix("bs") && k.count > 2 { k = String(k.dropFirst(2)) }
        return k
    }
    
    // The official program name for the text, or nil when it is not recognised
    static func officialName(for text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let exact = officialNames.first(where: { key($0) == key(trimmed) }) { return exact }
        return aliases[strippedKey(trimmed)] ?? aliases[key(trimmed)]
    }
    
    // Official name when recognised, otherwise the text as typed (trimmed)
    static func complete(_ text: String) -> String {
        officialName(for: text) ?? text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Official names that start with / contain the typed text (for suggestions)
    static func suggestions(for text: String) -> [String] {
        let k = key(text)
        guard !k.isEmpty else { return officialNames }
        var result: [String] = []
        if let official = officialName(for: text) { result.append(official) }
        for name in officialNames where key(name).contains(k) && !result.contains(name) {
            result.append(name)
        }
        return result
    }
}
