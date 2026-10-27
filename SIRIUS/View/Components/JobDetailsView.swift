//
//  JobDetailsView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

// Applicant-side job details. Shows the real job, the applicant's match breakdown,
// and whether they were applied automatically (60% minimum). There is no Apply button.
struct JobDetailsView: View {
    
    let listing: AplJobListing
    
    @Environment(\.dismiss) private var dismiss
    
    private var job: Job { listing.job }
    private var breakdown: MatchBreakdown { listing.breakdown }
    
    private let navy = Color(red: 0/255, green: 61/255, blue: 92/255)
    
    private var yearsText: String {
        let years = job.requiredYrExp
        if years <= 0 { return "No minimum" }
        let number = years == years.rounded() ? String(Int(years)) : String(format: "%.1f", years)
        return years == 1 ? "1 year" : "\(number) years"
    }
    
    private var statusText: String {
        if listing.hasApplied { return "Applied automatically" }
        if breakdown.isEligible { return "Eligible: you will be applied automatically" }
        return "Below the \(MatchRules.autoApplyThreshold)% minimum: not applied"
    }
    
    var body: some View {
        VStack{
            HStack{
                Button{
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.black)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white))
                }
                .accessibilityLabel("Back")
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            VStack(alignment: .leading){
                Text(job.jobPos)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(job.companyName.isEmpty ? "Company" : job.companyName)
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.bottom, 6)
                
                HStack{
                    infoPill(job.requiredLoc.isEmpty ? "Any location" : job.requiredLoc)
                    infoPill(job.workSetup.rawValue)
                    infoPill("Max hire: \(job.maxHire)")
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 15)
            .frame(width: 420, height: 123, alignment: .leading)
            .background(
                navy
                    .cornerRadius(10)
                    .offset(x: -20)
            )
            .cornerRadius(10)
            
            ScrollView{
                QualiMatchCard(
                    percentage: "\(breakdown.total)%",
                    title: "Qualification Match"
                )
                .padding(.bottom, 4)
                
                Text(statusText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.white))
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading){
                    Text("Job Description")
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.bottom, 5)
                    
                    Text(job.jobDesc.isEmpty ? "The employer did not add a description." : job.jobDesc)
                        .font(.system(size: 12))
                        .fontWeight(.regular)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 15)
                    
                    Text("Qualifications")
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.bottom, 5)
                    
                    card {
                        scoreRow("Educational Attainment", points: breakdown.education, outOf: 20)
                        chipRow([job.requiredEduc.isEmpty ? "Any program" : job.requiredEduc])
                    }
                    
                    card {
                        scoreRow("Minimum Work Experience", points: breakdown.experience, outOf: 20)
                        Text(yearsText)
                            .font(.system(size: 12))
                            .foregroundStyle(.black)
                    }
                    
                    card {
                        scoreRow("Core Languages", points: breakdown.languages, outOf: 60)
                        chipRow(job.requiredLang, matched: breakdown.matchedLanguages)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                .frame(width: 360)
                .background(navy)
                .cornerRadius(15)
                .padding(.bottom, 100)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 8)
        .appBg()
        .navigationBarBackButtonHidden(true)
    }
    
    private var statusColor: Color {
        switch breakdown.tier {
        case .high: return Color(red: 0/255, green: 126/255, blue: 6/255)
        case .medium: return Color(red: 243/255, green: 121/255, blue: 0/255)
        case .low: return Color(red: 160/255, green: 0/255, blue: 0/255)
        }
    }
    
    private func infoPill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 8))
            .fontWeight(.regular)
            .foregroundStyle(.black)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .frame(width: 110, height: 20)
            .background(Color.white)
            .cornerRadius(50)
    }
    
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            content()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(width: 310, alignment: .leading)
        .background(.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 4)
        .padding(.bottom, 10)
    }
    
    private func scoreRow(_ title: String, points: Int, outOf: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(.black)
            Spacer()
            Text("\(points)/\(outOf)")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(points == outOf ? Color(red: 0/255, green: 126/255, blue: 6/255) : Color.black)
        }
    }
    
    // Required items; the ones the applicant has are highlighted
    private func chipRow(_ items: [String], matched: [String] = []) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(items, id: \.self) { item in
                    let isMatched = matched.contains { Matching.normalized($0) == Matching.normalized(item) }
                    Text(item)
                        .font(.system(size: 8))
                        .fontWeight(isMatched ? .semibold : .regular)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 10)
                        .frame(minWidth: 60, minHeight: 15)
                        .background(isMatched ? Color.siriusMatchGreen.opacity(0.6) : Color.clear)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.black, lineWidth: 1))
                        .cornerRadius(5)
                }
            }
        }
        .frame(width: 270)
        .clipped()
    }
}
