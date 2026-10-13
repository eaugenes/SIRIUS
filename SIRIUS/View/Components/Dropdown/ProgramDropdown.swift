//
//  ProgramDropdown.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/10/26.
//

import SwiftUI

// "Program" dropdown (Figma: Dropdown Menu - EA).
// Uses the programs in ProgramsList and a native Menu, so it never overlaps other fields.
struct ProgramDropdown: View {
    let title: String
    let programs: [City]                // ProgramsList.programs (stored as City: id + name)
    @Binding var selectedProgram: String
    var borderColor: Color = .gray
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 13))
                .fontWeight(.medium)
                .foregroundStyle(Color.black)
                .padding(2)
            
            Menu {
                ForEach(programs) { program in
                    Button {
                        selectedProgram = program.name
                    } label: {
                        if program.name == selectedProgram {
                            Label(program.name, systemImage: "checkmark")
                        } else {
                            Text(program.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(selectedProgram.isEmpty ? "Select program" : selectedProgram)
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Color.siriusTextSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.gray)
                }
                .padding(.horizontal, 10)
                .frame(width: 300, height: 35)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(borderColor, lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    ProgramDropdown(
        title: "Program",
        programs: ProgramsList.programs,
        selectedProgram: .constant("BS Computer Science"),
        borderColor: .siriusPanel
    )
    .appBg()
}
