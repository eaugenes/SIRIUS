//
//  JobCard.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct AplJobCard: View {
    var jobTitle: String
    var companyName: String
    var jobLocation: String
    var jobSalary: String = ""            // empty hides the line (jobs have no salary field)
    var matchPrct: Double
    
    private var colorPrctText: Color {
        switch MatchTier(percentage: Int(matchPrct.rounded())) {
        case .high:
            return Color(red: 0/255, green: 126/255, blue: 6/255)   // DARK GREEN  (80-100)
        case .medium:
            return Color(red: 243/255, green: 121/255, blue: 0/255)     //  DARK ORANGE (60-79)
        case .low:
            return Color(red: 58/255, green: 2/255, blue: 2/255)    //  DARK RED (below 60)
        }
    }
    
    private var colorPrctBg: Color {
        switch MatchTier(percentage: Int(matchPrct.rounded())) {
        case .high:
            return Color(red: 139/255, green: 255/255, blue: 149/255)   // BRIGHT GREEN
        case .medium:
            return Color(red: 239/255, green: 173/255, blue: 68/255).opacity(0.54)     //  BRIGHT ORANGE
        case .low:
            return Color(red: 239/255, green: 68/255, blue: 68/255).opacity(0.45)     //  BRIGHT RED
        }
    }
    
    var body: some View {
        HStack(alignment: .top){
            VStack(alignment: .leading){
                Text(jobTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                
                Text(companyName)
                    .lineLimit(1)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.black)
                    .padding(.bottom, 1)
                
                Text(jobLocation)
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(Color.black)
                
                if !jobSalary.isEmpty {
                    Text(jobSalary)
                        .font(.system(size: 10, weight: .light))
                        .foregroundStyle(Color.black)
                }
            }
                
            Spacer()
            
            Text("\(matchPrct, specifier: "%.0f")%")           // percentage only (SIRIUS 2.0)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(colorPrctText)
                .frame(width: 70, height: 20)
                .background(colorPrctBg)
                .cornerRadius(15)
        }
        .padding(20)
        .frame(width: 350, height: 88)              // fixed size: never changes with text length
        .background(Color.white)
        .cornerRadius(10)
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

#Preview{
    AplJobCard(
        jobTitle: "Junior Software Developer",
        companyName: "OpeniT Philippines, Inc.",
        jobLocation: "San Juan City, Metro Manila",
        jobSalary: "₱40,000 - ₱50,000",
        matchPrct: 95
    )
}
