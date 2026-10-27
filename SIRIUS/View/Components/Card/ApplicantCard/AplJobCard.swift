//
//  JobCard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

// Percentage pill (70x20, radius 15): green 80+, orange 60-79, red below 60 (Figma "Final")
struct MatchPill: View {
    let percentage: Int
    
    private var textColor: Color {
        switch MatchTier(percentage: percentage) {
        case .high: return .siriusMatchGreenText
        case .medium: return .siriusMatchOrange
        case .low: return Color(red: 58/255, green: 2/255, blue: 2/255)
        }
    }
    
    private var fillColor: Color {
        switch MatchTier(percentage: percentage) {
        case .high: return .siriusMatchGreen
        case .medium: return .siriusMatchOrangeFill
        case .low: return Color(red: 239/255, green: 68/255, blue: 68/255).opacity(0.45)
        }
    }
    
    var body: some View {
        Text("\(percentage)%")
            .scaledFont(size: 8)
            .foregroundStyle(textColor)
            .frame(width: 70, height: 20)
            .background(fillColor)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .accessibilityLabel("\(percentage) percent match")
    }
}

// "Qualified Card": 88pt high white card (Jobs list, Home top match)
struct AplJobCard: View {
    var jobTitle: String
    var companyName: String
    var jobLocation: String
    var jobSalary: String = ""            // empty hides the line (jobs have no salary field yet)
    var matchPrct: Double
    var width: CGFloat = 339
    var isAutoApplied: Bool = false       // shows "✓ Auto-applied" at the bottom right
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(jobTitle)
                        .scaledFont(size: 14, weight: .bold)
                        .foregroundStyle(Color.siriusText)
                        .lineLimit(1)
                    
                    Spacer(minLength: 8)
                    
                    MatchPill(percentage: Int(matchPrct.rounded()))
                }
                
                Text(companyName)
                    .scaledFont(size: 10, weight: .medium)
                    .foregroundStyle(Color.siriusText)
                    .lineLimit(1)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(jobLocation)
                    .scaledFont(size: 10, weight: .light)
                    .foregroundStyle(Color.siriusText)
                    .lineLimit(1)
                
                if !jobSalary.isEmpty {
                    Text(jobSalary)
                        .scaledFont(size: 10, weight: .light)
                        .foregroundStyle(Color.siriusText)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .frame(width: width, alignment: .leading)
        .frame(minHeight: 88)       // fixed size: never changes with text length
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .overlay(alignment: .bottomTrailing) {
            if isAutoApplied {
                Text("\u{2713} Auto-applied")
                    .scaledFont(size: 10)
                    .foregroundStyle(Color(red: 0, green: 125/255, blue: 5/255))
                    .padding(.trailing, 14)
                    .padding(.bottom, 10)
            }
        }
    }
}

#Preview{
    AplJobCard(
        jobTitle: "Junior Software Developer",
        companyName: "OpeniT Philippines, Inc.",
        jobLocation: "San Juan City, Metro Manila",
        jobSalary: "₱40,000 - ₱50,000",
        matchPrct: 95,
        isAutoApplied: true
    )
}
