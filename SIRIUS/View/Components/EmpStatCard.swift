//
//  EmpStatCard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/6/26.
//

import SwiftUI

struct EmpStatCard: View {
    
    let value: Int
    let title: String
    
    var body: some View {
        HStack(spacing: 10) {
            Text("\(value)")
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 61)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 4, y: 4)
    }
}

// Navy → green → navy "90% Average Match" banner
struct EmpAverageMatchCard: View {
    let percentage: Int
    
    var body: some View {
        HStack(spacing: 9) {
            Text("\(percentage)%")
                .font(.system(size: 30, weight: .medium))
            
            Text("Average Match")
                .font(.system(size: 18))
        }
        .foregroundStyle(Color.black)
        .frame(maxWidth: .infinity)
        .frame(height: 61)
        .background(
            LinearGradient(
                stops: [
                    .init(color: .siriusNavy, location: 0.01),
                    .init(color: .siriusMatchGreen, location: 0.49),
                    .init(color: .siriusNavy, location: 0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 4, y: 4)
    }
}

#Preview {
    VStack(spacing: 13) {
        EmpAverageMatchCard(percentage: 90)
        HStack(spacing: 26) {
            EmpStatCard(value: 200, title: "Applicants")
            EmpStatCard(value: 200, title: "To Review")
        }
    }
    .padding(.horizontal, 32)
    .appBg()
}
