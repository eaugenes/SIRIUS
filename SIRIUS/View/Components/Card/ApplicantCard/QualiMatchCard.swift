//
//  QualiMatchCard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

// Home "Average Qualification Match" (100 high, big %) when subtext is given;
// otherwise the 37pt "N% Qualification Match · status" banner used on job details.
struct QualiMatchCard: View {
    var percentage: String
    var title: String
    var subtext: String?
    var endColor: Color = Color.siriusMatchGreen.opacity(0.8)       // gradient end (green / orange / red by tier)
    
    private var hasSubtext: Bool {
        if let subtext = subtext {
            return !subtext.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        return false
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(red: 4/255, green: 48/255, blue: 96/255).opacity(0.8), location: 0.1),
                .init(color: endColor, location: 1.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        Group {
            if hasSubtext, let subtext = subtext {
                HStack(spacing: 26) {
                    Text(percentage)
                        .scaledFont(size: 42, weight: .medium)
                        .foregroundColor(.white)
                        .frame(width: 94)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .scaledFont(size: 14, weight: .bold)
                            .foregroundColor(.white)
                        
                        Text(subtext)
                            .scaledFont(size: 13, weight: .medium)
                            .foregroundColor(.white)
                    }
                    .frame(width: 182, alignment: .leading)
                }
                .fluidFrame(width: 360, height: 100)
            } else {
                Text("\(percentage) \(title)")
                    .scaledFont(size: 15, weight: .medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 37)
            }
        }
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(
            color: Color(red: 4/255, green: 48/255, blue: 96/255),
            radius: hasSubtext ? 1.5 : 2.5,
            x: 3,
            y: 3
        )
    }
}

#Preview {
    VStack {
        QualiMatchCard(percentage: "90%", title: "Average Qualification Match", subtext: "12 matched \u{00B7} auto-applied")
        QualiMatchCard(percentage: "90%", title: "Qualification Match \u{00B7} Auto-applied")
            .fluidFrame(width: 370)
    }
    .appBg()
}
