//
//  MatchExplanationCard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

// "Why N%": the points earned in each category with a plain-language reason,
// plus the location note (location is shown but does not change the score).
struct MatchExplanationCard: View {
    
    let job: Job
    let profile: MatchProfile
    let breakdown: MatchBreakdown
    var onNavy: Bool = false            // true inside the navy description panel (white text)
    
    private var primary: Color { onNavy ? .white : .siriusInk }
    private var secondary: Color { onNavy ? Color.white.opacity(0.8) : .siriusMuted }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Why \(breakdown.total)%?")
                    .scaledFont(size: 16, weight: .semibold)
                    .foregroundStyle(primary)
                Spacer()
                Text(breakdown.isEligible
                     ? "Meets the \(MatchRules.autoApplyThreshold)% minimum"
                     : "Below the \(MatchRules.autoApplyThreshold)% minimum")
                    .scaledFont(size: 11, weight: .medium)
                    .foregroundStyle(breakdown.isEligible ? Color.siriusMatchBar : Color.siriusBarAmber)
            }
            
            ForEach(Matching.explain(profile, against: job.matchRequirements, breakdown: breakdown)) { line in
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(line.title)
                            .scaledFont(size: 13, weight: .semibold)
                            .foregroundStyle(primary)
                        Spacer()
                        Text("\(line.score) / \(line.outOf)")
                            .scaledFont(size: 13, weight: .semibold)
                            .foregroundStyle(line.score == line.outOf ? Color.siriusMatchBar : primary)
                    }
                    Text(line.detail)
                        .scaledFont(size: 11)
                        .foregroundStyle(secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
            }
            
            if let locationMatches = breakdown.locationMatches {
                HStack(spacing: 6) {
                    Image(systemName: locationMatches ? "mappin.and.ellipse" : "mappin.slash")
                    Text(locationMatches
                         ? "Location matches the employer's preferred area."
                         : "The employer prefers \(job.requiredLoc). Location doesn't change your score.")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .scaledFont(size: 11)
                .foregroundStyle(secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
