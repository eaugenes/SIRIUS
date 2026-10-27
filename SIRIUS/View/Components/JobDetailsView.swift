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
    
    
    private var yearsText: String {
        let years = job.requiredYrExp
        if years <= 0 { return "No minimum" }
        let number = years == years.rounded() ? String(Int(years)) : String(format: "%.1f", years)
        return years == 1 ? "1 year" : "\(number) years"
    }
    
    private var statusText: String {
        listing.hasApplied ? "Auto-applied" : "Not applied"
    }
    
    private var bannerEndColor: Color {
        switch breakdown.tier {
        case .high: return Color.siriusMatchGreen.opacity(0.8)
        case .medium: return Color(red: 239/255, green: 173/255, blue: 68/255)
        case .low: return Color(red: 229/255, green: 69/255, blue: 69/255)      // #e54545
        }
    }
    
    // Figma "Final": Jobs Details Screen (back button, job frame, match banner, description + qualifications)
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 28) {
                QualiMatchCard(
                    percentage: "\(breakdown.total)%",
                    title: "Qualification Match \u{00B7} \(statusText)",
                    endColor: bannerEndColor
                )
                
                descriptionPanel
            }
            .fluidFrame(width: 370)
            .padding(.leading, 16)
            .padding(.top, 277)
            
            jobPositionFrame
                .padding(.top, 135)
            
            Button{
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .scaledFont(size: 20)
                    .foregroundStyle(Color.siriusText)
                    .frame(width: 42, height: 42)
                    .background(Color.siriusSurface)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.18), radius: 1.5, x: 0, y: 2)
            }
            .accessibilityLabel("Back")
            .padding(.leading, 16)
            .padding(.top, 75)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .ignoresSafeArea(.container, edges: .top)
        .appBg()
        .navigationBarBackButtonHidden(true)
    }
    
    // Job Position Frame: x -11 ... 386, 123 high, title / company / info pills
    private var jobPositionFrame: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text(job.jobPos)
                    .scaledFont(size: 20, weight: .semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text((job.companyName.isEmpty ? "Company" : job.companyName)
                     + (job.salary > 0 ? "  |  \(job.salaryText) / month" : ""))
                    .scaledFont(size: 12, weight: .medium)
                    .lineLimit(1)
            }
            .foregroundStyle(Color.white)
            
            HStack(spacing: 11) {
                infoPill("Max hire: \(job.maxHire)", width: 119)
                infoPill(job.requiredLoc.isEmpty ? "Any location" : job.requiredLoc, width: 101)
                infoPill(job.workSetup.rawValue, width: 101)
            }
        }
        .padding(.leading, 40)
        .padding(.vertical, 15)
        .frame(width: 397, height: 123, alignment: .leading)
        .background(Color.siriusNavy)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 4, y: 4)
        .offset(x: -11)
    }
    
    // Navy scroll panel (370 x 517, radius 20)
    private var descriptionPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 11) {
                    Text("Job Description")
                        .scaledFont(size: 18, weight: .bold)
                    
                    Text(job.jobDesc.isEmpty ? "The employer did not add a description." : job.jobDesc)
                        .scaledFont(size: 12, weight: .medium)
                        .lineSpacing(8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(Color.white)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Qualifications")
                        .scaledFont(size: 18, weight: .bold)
                        .foregroundStyle(Color.white)
                    
                    card {
                        Text("Program")
                            .scaledFont(size: 12)
                            .foregroundStyle(Color.siriusText)
                        chipRow(Matching.parsePrograms(job.requiredProgram).isEmpty ? ["Any program"] : Matching.parsePrograms(job.requiredProgram), width: 150)
                    }
                    
                    HStack {
                        Text("Minimum Work Experience: ")
                        Spacer()
                        Text(yearsText)
                    }
                    .scaledFont(size: 12)
                    .foregroundStyle(Color.siriusText)
                    .padding(.horizontal, 12)
                    .frame(width: 322, height: 44)
                    .background(Color.siriusSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 4, y: 4)
                    
                    card {
                        Text("Core Languages")
                            .scaledFont(size: 12)
                            .foregroundStyle(Color.siriusText)
                        chipRow(job.requiredLang, width: 100)
                    }
                }
                
                MatchExplanationCard(job: job, profile: listing.profile, breakdown: breakdown, onNavy: true)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 517)
        .background(Color.siriusNavy)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 4, y: 4)
    }
    
    private func infoPill(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .scaledFont(size: 8)
            .foregroundStyle(Color.siriusText)
            .lineLimit(1)
            .frame(width: width, height: 20)
            .background(Color.siriusSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(width: 322, alignment: .leading)
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.25), radius: 4, x: 4, y: 4)
    }
    
    // Required items as outlined chips (15 high, radius 5, navy border)
    private func chipRow(_ items: [String], width: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .scaledFont(size: 10)
                        .foregroundStyle(Color.siriusText)
                        .lineLimit(1)
                        .padding(.horizontal, 6)
                        .frame(minWidth: width, minHeight: 15)
                        .background(Color.siriusSurface)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.siriusNavy, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
        }
    }
}
