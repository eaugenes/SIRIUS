//
//  CitiesDropdown.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/10/26.
//

import SwiftUI

struct CitiesDropdown: View {
    let title: String
    let cities: [City]
    @Binding var selectedCity: City?
    var borderColor: Color = .siriusBorder

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .scaledFont(size: 13)
                .fontWeight(.medium)
                .foregroundStyle(Color.siriusInk)
                .padding(.leading, 11)

            Menu {
                ForEach(cities) { city in
                    Button {
                        selectedCity = city
                    } label: {
                        if city == selectedCity {
                            Label(city.name, systemImage: "checkmark")
                        } else {
                            Text(city.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(selectedCity?.name ?? "Select city")
                        .scaledFont(size: 14, weight: .light)
                        .foregroundStyle(Color.siriusTextSecondary)
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .scaledFont(size: 16, weight: .semibold)
                        .foregroundStyle(Color.gray)
                }
                .padding(.horizontal, 10)
                .frame(width: 300)
                .frame(minHeight: 35)
                .background(Color.siriusSurface)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(borderColor, lineWidth: 1)
                )
            }
        }
    }
}
