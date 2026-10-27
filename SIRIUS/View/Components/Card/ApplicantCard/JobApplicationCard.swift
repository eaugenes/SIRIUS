//
//  JobApplicationCard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/16/26.
//

import SwiftUI

// "Qualified Card" in My Applications / Recent Activity (Figma "Final": 333 x 88)
struct JobApplicationCard: View {
    let application: JobApplication
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10).fill(Color.siriusSurface)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(application.role)
                    .scaledFont(size: 14, weight: .bold)
                    .foregroundColor(Color.siriusText)
                    .lineLimit(1)
                    .frame(width: 155, height: 22, alignment: .leading)
                    .padding(.top, 16.5)
                
                Text(application.company)
                    .scaledFont(size: 10, weight: .medium)
                    .foregroundColor(Color.siriusText)
                    .lineLimit(1)
                    .frame(width: 155, height: 15, alignment: .leading)
                    .padding(.top, 2)
                
                Text("Applied on \(application.dateApplied)")
                    .scaledFont(size: 10, weight: .light)
                    .foregroundColor(Color.siriusText)
                    .lineLimit(1)
                    .frame(width: 170, alignment: .leading)
                    .padding(.top, 5)
            }
            .padding(.leading, 18)
            
            MatchPill(percentage: application.matchPercentage)
                .offset(x: 250, y: 17)
            
            Text(application.status.rawValue)
                .scaledFont(size: 8, weight: .bold)
                .foregroundStyle(Color.white)
                .frame(width: 70, height: 20)
                .background(Color.siriusPanel)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .offset(x: 250, y: 43)
        }
        .fluidFrame(width: 333, height: 88)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(application.role) at \(application.company), applied on \(application.dateApplied), \(application.matchPercentage) percent match, \(application.status.rawValue)")
        .accessibilityHint("Opens application details")
    }
}
