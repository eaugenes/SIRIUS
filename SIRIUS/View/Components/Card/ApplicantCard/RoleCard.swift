//
//  RoleCard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

// Role option on Choose Role (Figma "Final": 88pt high, radius 18, radio at the bottom right)
struct RoleCard: View {
    
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .scaledFont(size: 22)
                    .foregroundStyle(Color.siriusAction)
                    .frame(width: 52, height: 52)
                    .background(isSelected ? Color.white : Color.siriusRoleTile)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .scaledFont(size: 16, weight: .bold)
                        .foregroundStyle(isSelected ? Color.white : Color.siriusInk)
                        .lineLimit(1)
                    
                    Text(description)
                        .scaledFont(size: 12)
                        .lineSpacing(0)
                        .foregroundStyle(isSelected ? Color.siriusRoleSub : Color.siriusMuted)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background(isSelected ? Color.siriusAction : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(isSelected ? Color.clear : Color.siriusFieldBorder, lineWidth: 1.5)
            )
            .shadow(color: isSelected ? Color(red: 0, green: 38/255, blue: 64/255).opacity(0.35) : .clear, radius: 5, x: 0, y: 4)
            .overlay(alignment: .bottomTrailing) { selectionIndicator }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    // Radio: white circle with a checkmark when selected, ring when not
    private var selectionIndicator: some View {
        ZStack {
            if isSelected {
                Circle().fill(Color.siriusSurface)
                Image(systemName: "checkmark")
                    .scaledFont(size: 9, weight: .bold)
                    .foregroundStyle(Color.siriusAction)
            } else {
                Circle().strokeBorder(Color.siriusFieldBorder, lineWidth: 1.5)
            }
        }
        .frame(width: 18, height: 18)
        .padding(.trailing, 16)
        .padding(.bottom, 10)
    }
}
