//
//  WorkSetupPicker.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/13/26.
//

import SwiftUI

// "On-site | Remote | Hybrid" selector (Figma: Textfield - Work Setup)
struct WorkSetupPicker: View {

    let title: String
    @Binding var selection: WorkSetup
    var borderColor: Color = .siriusFieldBorder

    private let selectedFill = Color(red: 240/255, green:240/255, blue:240/255)
    private let secondaryText = Color(red: 74/255, green:74/255, blue:74/255)
    private let options: [WorkSetup] = [.onSite, .remote, .hybrid]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .scaledFont(size: 13)
                .fontWeight(.medium)
                .foregroundStyle(Color.siriusInk)
                .padding(.leading, 11)

            HStack(spacing: 0) {
                ForEach(options, id: \.rawValue) { setup in
                    segment(for: setup)
                }
            }
            .frame(width: 300)
                    .frame(minHeight: 35)
            .background(Color.siriusFieldFill)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
        }
    }
                
    // One option button (On-site / Remote / Hybrid)
    private func segment(for setup: WorkSetup) -> some View {
        let isSelected: Bool = (selection.rawValue == setup.rawValue)
        let textColor: Color = isSelected ? Color.black : secondaryText
        let fillColor: Color = isSelected ? selectedFill : Color.white
        let weight: Font.Weight = isSelected ? .regular : .light
        
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selection = setup
            }
        } label: {
            Text(setup.rawValue)
                .scaledFont(size: 14, weight: weight)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(fillColor)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WorkSetupPicker(title: "Work Setup", selection: .constant(.onSite), borderColor: .blue)
        .appBg()
}
