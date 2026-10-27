//
//  EmpActivityCard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/6/26.
//

import SwiftUI

// One "Recent Activity" row: icon, title, job position, time
struct EmpActivityCard: View {
    let activity: EmpActivity
    
    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            Image(systemName: activity.icon)
                .scaledFont(size: 15)
                .foregroundStyle(Color.white)
                .frame(width: 45, height: 45)
                .background(Circle().fill(Color.siriusNavy))
                .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text(activity.title)
                        .scaledFont(size: 14, weight: .bold)
                        .foregroundStyle(Color.siriusText)
                        .lineLimit(1)
                    
                    Spacer(minLength: 6)
                    
                    Text(activity.timeAgo)
                        .scaledFont(size: 10, weight: .light)
                        .foregroundStyle(Color.siriusText)
                }
                
                Text(activity.jobPosition)
                    .scaledFont(size: 13, weight: .light)
                    .foregroundStyle(Color.siriusText)
                    .lineLimit(1)
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 14)
        .fluidFrame(width: 335, height: 64)
        .background(Color.siriusSurface)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.5), radius: 1, x: 0, y: 4)
    }
}

#Preview {
    VStack(spacing: 14) {
        EmpActivityCard(activity: EmpInfoController.sampleActivity[0])
        EmpActivityCard(activity: EmpInfoController.sampleActivity[1])
    }
    .appBg()
}
