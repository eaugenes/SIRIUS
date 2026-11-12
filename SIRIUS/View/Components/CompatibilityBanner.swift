//
//  CompatibilityBanner.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI

enum CompatibilityLevel: Equatable {
    case lower          // below 80%  : mostly blue, a hint of green at the end
    case balanced       // 80 - 89%   : blue and green in equal parts
    case higher         // 90% and up : mostly green
    
    init(percentage: Int) {
        if percentage >= 90 {
            self = .higher
        } else if percentage >= MatchRules.greenMinimum {
            self = .balanced
        } else {
            self = .lower
        }
    }
    
    var stops: [Gradient.Stop] {
        switch self {
        case .lower:
            return [
                .init(color: .siriusNavy, location: 0.0),
                .init(color: .siriusNavy, location: 0.6),
                .init(color: .siriusMatchBar, location: 1.0)
            ]
        case .balanced:
            return [
                .init(color: .siriusNavy, location: 0.0),
                .init(color: .siriusMatchBar, location: 1.0)
            ]
        case .higher:
            return [
                .init(color: .siriusNavy, location: 0.0),
                .init(color: .siriusMatchBar, location: 0.4),
                .init(color: .siriusMatchBar, location: 1.0)
            ]
        }
    }
}

// "Compatibility with the job" banner on the employer's Applicant Details.
// A navy-to-green gradient replaces the old plain heading; the percentage sits in a white pill.
struct CompatibilityBanner: View {
    
    let percentage: Int
    var title: String = "Compatibility with the job"
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .scaledFont(size: 14, weight: .semibold)
                .foregroundStyle(Color.white)
                .shadow(color: Color.black.opacity(0.35), radius: 1.5, x: 0, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Spacer(minLength: 6)
            
            Text("\(percentage)%")
                .scaledFont(size: 15, weight: .bold)
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 12)
                .frame(minWidth: 56)
                .frame(height: 28)
                .background(Capsule().fill(Color.white))
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(
            LinearGradient(
                stops: CompatibilityLevel(percentage: percentage).stops,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title): \(percentage) percent")
    }
}

#Preview {
    VStack(spacing: 12) {
        CompatibilityBanner(percentage: 72)
        CompatibilityBanner(percentage: 85)
        CompatibilityBanner(percentage: 98)
    }
    .padding(20)
    .appBg()
}
