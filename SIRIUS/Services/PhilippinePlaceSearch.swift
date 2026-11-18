//
//  PhilippinePlaceSearch.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/17/26.
//

import Foundation
import MapKit
import Combine

struct PhilippinePlace: Equatable {
    let name: String
    let address: String

    var displayText: String {
        address.isEmpty || address == name ? name : "\(name), \(address)"
    }
}

enum PhilippinePlaceError: LocalizedError {
    case notInPhilippines
    case notFound

    var errorDescription: String? {
        switch self {
        case .notInPhilippines: return "Please choose a location in the Philippines."
        case .notFound: return "Couldn't find that place. Try another one."
        }
    }
}

final class PhilippinePlaceSearch: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {

    @Published private(set) var suggestions: [MKLocalSearchCompletion] = []

    static let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.8797, longitude: 121.7740),
        span: MKCoordinateSpan(latitudeDelta: 18, longitudeDelta: 12)
    )

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.region = Self.region
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func update(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count < 2 {
            suggestions = []
            completer.cancel()
        } else {
            completer.queryFragment = trimmed
        }
    }

    func clear() {
        completer.cancel()
        suggestions = []
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = Array(completer.results.prefix(5))
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }

    func resolve(_ completion: MKLocalSearchCompletion) async throws -> PhilippinePlace {
        let request = MKLocalSearch.Request(completion: completion)
        request.region = Self.region
        let response = try await MKLocalSearch(request: request).start()

        guard !response.mapItems.isEmpty else { throw PhilippinePlaceError.notFound }
        guard let item = response.mapItems.first(where: { $0.placemark.isoCountryCode == "PH" }) else {
            throw PhilippinePlaceError.notInPhilippines
        }

        let placemark = item.placemark
        let name = (item.name ?? completion.title).trimmingCharacters(in: .whitespacesAndNewlines)

        var parts: [String] = []
        for piece in [placemark.thoroughfare, placemark.subLocality, placemark.locality, placemark.administrativeArea] {
            guard let piece, !piece.isEmpty, piece != name, !parts.contains(piece) else { continue }
            parts.append(piece)
        }
        return PhilippinePlace(name: name, address: parts.joined(separator: ", "))
    }
}
