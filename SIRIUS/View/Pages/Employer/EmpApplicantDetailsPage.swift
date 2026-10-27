//
//  EmpApplicantDetailsPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct EmpApplicantDetailsPage: View {
    
    let applicantID: UUID
    
    @EnvironmentObject private var aplController: EmpAplStatusController
    @Environment(\.dismiss) private var dismiss
    
    @State private var confirmRemove = false
    
    private var applicant: EmpApplicant? {
        aplController.applicants.first { $0.id == applicantID }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let applicant {
                content(for: applicant)
            } else {
                // The applicant was removed
                VStack(spacing: 12) {
                    Text("This applicant is no longer available.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.siriusNavy)
                    SiriusButton(title: "Back") { dismiss() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .appBg()
        .navigationBarBackButtonHidden(true)
        .alert("Remove applicant?", isPresented: $confirmRemove) {
            Button("Remove", role: .destructive) {
                if let applicant {
                    aplController.removeApplicant(applicant)
                }
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\(applicant?.name ?? "This applicant") will be removed from your applicants.")
        }
    }
    
    private func content(for applicant: EmpApplicant) -> some View {
        let result = applicant.breakdown
        
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.black)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white))
                }
                .accessibilityLabel("Back")
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(applicant.name)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(applicant.jobPosition)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 16)
            
            ScrollView {
                VStack(spacing: 14) {
                    infoCard(applicant)
                    
                    if let result {
                        overallCard(result)
                        breakdownCard(applicant, result)
                    }
                    
                    FormErrorText(message: aplController.actionError)
                    actions(applicant)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(16)
        .frame(width: 338, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
    
    private func infoCard(_ applicant: EmpApplicant) -> some View {
        card {
            detailRow("Program", applicant.degree)
            detailRow("Work experience", applicant.experienceText.replacingOccurrences(of: " work experience", with: ""))
            detailRow("Stage", applicant.status.rawValue)
            VStack(alignment: .leading, spacing: 4) {
                Text("Core languages")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.siriusTextSecondary)
                chips(applicant.coreLanguages, highlighted: applicant.breakdown?.matchedLanguages ?? [])
            }
        }
    }
    
    // Overall percentage next to the 60% minimum, coloured green / orange / red
    private func overallCard(_ result: MatchBreakdown) -> some View {
        card {
            HStack {
                Text("Overall match")
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text("\(result.total)%")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(color(for: result.tier))
            }
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.siriusFill)
                    Capsule()
                        .fill(color(for: result.tier))
                        .frame(width: proxy.size.width * CGFloat(result.total) / 100)
                    // Minimum marker
                    Rectangle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 2)
                        .offset(x: proxy.size.width * CGFloat(MatchRules.autoApplyThreshold) / 100)
                }
            }
            .frame(height: 10)
            
            Text(result.isEligible
                 ? "Meets the \(MatchRules.autoApplyThreshold)% minimum"
                 : "Below the \(MatchRules.autoApplyThreshold)% minimum")
                .font(.system(size: 11))
                .foregroundStyle(result.isEligible ? Color.siriusTextSecondary : Color.siriusDanger)
        }
    }
    
    private func breakdownCard(_ applicant: EmpApplicant, _ result: MatchBreakdown) -> some View {
        card {
            Text("Compatibility")
                .font(.system(size: 13, weight: .medium))
            scoreRow("Education", result.education, 20)
            scoreRow("Work Experience", result.experience, 20)
            scoreRow("Languages", result.languages, 60)
            
            if !result.missingLanguages.isEmpty {
                Text("Missing: \(result.missingLanguages.joined(separator: ", "))")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.siriusDanger)
            }
        }
    }
    
    @ViewBuilder
    private func actions(_ applicant: EmpApplicant) -> some View {
        VStack(spacing: 10) {
            if applicant.status == .toReview {
                SiriusButton(title: "Schedule Interview") {
                    aplController.beginScheduling(applicant)
                    dismiss()                       // the dialog opens on the applicants list
                }
            }
            if applicant.status == .interview {
                SiriusButton(title: "Hire") {
                    aplController.hire(applicant)
                }
            }
            SiriusButton(title: "Remove Applicant", isFilled: false) {
                confirmRemove = true
            }
        }
    }
    
    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(Color.siriusTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.black)
        }
    }
    
    private func scoreRow(_ title: String, _ points: Int, _ outOf: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12))
            Spacer()
            Text("\(points)/\(outOf)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(points == outOf ? Color.siriusMatchBar : Color.black)
        }
    }
    
    private func chips(_ items: [String], highlighted: [String]) -> some View {
        HStack(spacing: 6) {
            ForEach(items, id: \.self) { item in
                let isMatched = highlighted.contains { Matching.normalized($0) == Matching.normalized(item) }
                Text(item)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(isMatched ? Color.white : Color.black)
                    .padding(.horizontal, 10)
                    .frame(height: 16)
                    .background(isMatched ? Color.siriusNavy : Color.siriusFill)
                    .cornerRadius(8)
            }
        }
    }
    
    private func color(for tier: MatchTier) -> Color {
        switch tier {
        case .high: return Color.siriusMatchBar
        case .medium: return Color(red: 243/255, green: 121/255, blue: 0/255)
        case .low: return Color.siriusDanger
        }
    }
}
