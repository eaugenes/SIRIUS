//
//  LocalSnapshot.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/18/26.
//

import Foundation

enum LocalSnapshot {

    private static func fileURL(_ name: String, userID: UUID) -> URL? {
        guard let base = try? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        ) else { return nil }
        let folder = base.appendingPathComponent("SIRIUS", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("\(name)-\(userID.uuidString.lowercased()).json")
    }

    static func save<T: Encodable>(_ value: T, name: String, userID: UUID) {
        guard let url = fileURL(name, userID: userID),
              let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: url, options: [.atomic, .completeFileProtection])
    }

    static func load<T: Decodable>(_ type: T.Type, name: String, userID: UUID) -> T? {
        guard let url = fileURL(name, userID: userID),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    static func remove(name: String, userID: UUID) {
        guard let url = fileURL(name, userID: userID) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
