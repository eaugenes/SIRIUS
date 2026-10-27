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
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading){
            Text(title)
                .scaledFont(size: 13)
                .fontWeight(.medium)
                .foregroundStyle(Color.siriusInk)
                .padding(.leading, 11)
                .padding(.bottom, 3)
            
            VStack{
                Button {
                    isExpanded.toggle()
                } label: {
                    HStack{
                        Text(selectedCity?.name ?? "Select City")
                            .scaledFont(size: 13)
                            .fontWeight(.regular)
                        
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .scaledFont(size: 13)
                            .fontWeight(.regular)
                    }
                    .scaledFont(size: 12)
                    .padding(10)
                    .visibleEdges(
                        isExpanded ? [.top, .leading, .trailing] : [.top, .bottom, .leading, .trailing],
                        color: .gray,
                        width: 1)
                    .foregroundStyle(Color(.gray.opacity(0.7)))
                    .background(Color.siriusSurface)
                    .clipShape(
                        UnevenRoundedRectangle(             // Customize corner radius
                            topLeadingRadius: 10,
                            bottomLeadingRadius: isExpanded ? 0 : 10,
                            bottomTrailingRadius: isExpanded ? 0 :10,
                            topTrailingRadius: 10
                        )
                    )
                    .frame(width: 300)
                    .frame(minHeight: 35)
                }
                .overlay(
                    VStack{
                        if isExpanded{
                            ScrollView{
                                VStack{
                                    ForEach(cities) { city in
                                        Button {
                                            selectedCity = city
                                            isExpanded = false
                                        } label: {
                                            HStack{
                                                Text(city.name)
                                                    .scaledFont(size: 12)
                                                    .fontWeight(.medium)
                                                    .foregroundStyle(Color.gray)
                                                
                                                Spacer()
                                                
                                                if city == selectedCity {
                                                    Image(systemName: "checkmark")
                                                        .foregroundStyle(Color(.black))
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .frame(width: 270, height: 30)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        Divider()
                                    }
                                }
                                .background(Color.siriusSurface)
                            }
                            .clipShape(
                                UnevenRoundedRectangle(             // Customize corner radius
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 10,
                                    bottomTrailingRadius: 10,
                                    topTrailingRadius: 0
                                )
                            )
                            .visibleEdges(          // To Be Improve
                                [.bottom, .leading, .trailing],
                                color: .gray,
                                width: 1
                            )
                            .frame(minWidth: 300, maxHeight: 90)
                            .offset(x: 0, y: 60)           //  To Show Below The Dropdown
                        }
                    }
                    .frame(width: 290, height: 400)
                )
            }
        }
    }
}
