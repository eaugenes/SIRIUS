//
//  ProgramMultiDropdown.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

// Program dropdown that allows several programs to be ticked (used on Job Posting).
// Tap a program to add / remove it; the menu lists a checkmark next to every chosen one.
struct ProgramMultiDropdown: View {
    let title: String
    let programs: [City]
    @Binding var selectedPrograms: [String]
    var borderColor: Color = .siriusBorder
    
    private var summary: String {
        selectedPrograms.isEmpty ? "Select program(s)" : selectedPrograms.joined(separator: ", ")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .scaledFont(size: 13)
                .fontWeight(.medium)
                .foregroundStyle(Color.siriusInk)
                .padding(.leading, 11)
            
            Menu {
                ForEach(programs) { program in
                    Button {
                        toggle(program.name)
                    } label: {
                        if selectedPrograms.contains(program.name) {
                            Label(program.name, systemImage: "checkmark")
                        } else {
                            Text(program.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(summary)
                        .scaledFont(size: 14, weight: .light)
                        .foregroundStyle(Color.siriusTextSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
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
            
            // Chosen programs as removable chips
            if !selectedPrograms.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(selectedPrograms, id: \.self) { name in
                        Button {
                            toggle(name)
                        } label: {
                            HStack(spacing: 4) {
                                Text(name).lineLimit(1)
                                Image(systemName: "xmark")
                                    .scaledFont(size: 8, weight: .bold)
                            }
                            .scaledFont(size: 11, weight: .medium)
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 10)
                            .frame(height: 22)
                            .background(Capsule().fill(Color.siriusAction))
                        }
                    }
                }
                .padding(.leading, 11)
                .frame(width: 300, alignment: .leading)
            }
        }
    }
    
    private func toggle(_ name: String) {
        if let index = selectedPrograms.firstIndex(of: name) {
            selectedPrograms.remove(at: index)
        } else {
            // keep the list in the same order as the menu
            selectedPrograms.append(name)
            let order = programs.map(\.name)
            selectedPrograms.sort { (order.firstIndex(of: $0) ?? 0) < (order.firstIndex(of: $1) ?? 0) }
        }
    }
}
