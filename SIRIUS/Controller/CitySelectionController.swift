//
//  CitySelectionController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/10/26.
//

import Foundation
import Combine

final class CitySelectionController: ObservableObject {

    @Published var selectedCity: City?
    @Published var selectedCities: [City] = []

    let cities = CalabarzonCitiesData.cities

    func selectCity(_ city: City) {
        selectedCity = city
    }

    func toggleCity(_ city: City) {
        if selectedCities.contains(city) {
            selectedCities.removeAll(where: { $0.id == city.id })
        } else {
            selectedCities.append(city)
        }
    }

    func isSelected(_ city: City) -> Bool {
        selectedCities.contains(city)
    }

    func clearSelection() {
        selectedCity = nil
        selectedCities.removeAll()
    }
}
