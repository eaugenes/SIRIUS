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
    
    @State private var showReject = false
    
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
                        .scaledFont(size: 14, weight: .medium)
                        .foregroundStyle(Color.siriusInk)
                    SiriusButton(title: "Back") { dismiss() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .appBg()
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showReject) {
            if let applicant {
                RejectApplicantDialog(
                    applicantName: applicant.name,
                    onReject: { reason in
                        aplController.removeApplicant(applicant, reason: reason)
                        showReject = false
                        dismiss()
                    },
                    onCancel: { showReject = false }
                )
            }
        }
        .boardLoadState()
    }
    
    private func content(for applicant: EmpApplicant) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 14) {
                CircleBackButton { dismiss() }
                Text("Applicant Details")
                    .scaledFont(size: 24, weight: .medium)
                    .foregroundStyle(Color.white)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
            
            ScrollView {
                VStack(spacing: 14) {
                    mainCard(applicant)
                    extrasCard(applicant)
                    FormErrorText(message: aplController.actionError)
                    actions(applicant)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    // Single white card: profile, compatibility rows, language chips, overall match
    private func mainCard(_ applicant: EmpApplicant) -> some View {
        let result = applicant.breakdown
        let matched = result?.matchedLanguages ?? []
        let years = applicant.jobMinYears
        let yearsText = years <= 0 ? "No minimum" : "\(years == years.rounded() ? String(Int(years)) : String(years)) years or more"
        let programs = Matching.parsePrograms(applicant.jobProgram).joined(separator: ", ")
        let langs = applicant.jobRequiredLanguages.joined(separator: ", ")
        
        return VStack(alignment: .leading, spacing: 0) {
            Text(applicant.name)
                .scaledFont(size: 24, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
            Text(applicant.degree)
                .scaledFont(size: 14)
                .foregroundStyle(Color.siriusMuted)
                .padding(.top, 4)
            Text(applicant.experienceText)
                .scaledFont(size: 14)
                .foregroundStyle(Color.siriusMuted)
            Text("Applied to: \(applicant.jobPosition)")
                .scaledFont(size: 12, weight: .semibold)
                .foregroundStyle(Color.siriusAction)
                .padding(.top, 10)
            
            Divider().padding(.vertical, 14)
            
            Text("Compatibility with the job")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusAction)
            
            if let result {
                VStack(alignment: .leading, spacing: 12) {
                    scoreRow("Program", result.program, 20, programs.isEmpty ? "Required: Any program" : "Required: \(programs)")
                    scoreRow("Work experience", result.experience, 20, "Required: \(yearsText)")
                    scoreRow("Programming languages", result.languages, 60, langs.isEmpty ? "Required: Any" : "Required: \(langs)")
                }
                .padding(.top, 12)
                
                HStack(spacing: 6) {
                    ForEach(applicant.coreLanguages, id: \.self) { item in
                        let isMatched = matched.contains { Matching.normalized($0) == Matching.normalized(item) }
                        Text(isMatched ? "✓ \(item)" : item)
                            .scaledFont(size: 11, weight: .medium)
                            .foregroundStyle(isMatched ? Color.white : Color.siriusInk)
                            .padding(.horizontal, 10)
                            .frame(height: 22)
                            .background(Capsule().fill(isMatched ? Color.siriusMatchBar : Color.siriusFill))
                    }
                }
                .padding(.top, 14)
                
                Divider().padding(.vertical, 14)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Overall match")
                            .scaledFont(size: 16, weight: .semibold)
                            .foregroundStyle(Color.siriusInk)
                        Text("Minimum qualification: \(MatchRules.autoApplyThreshold)% match")
                            .scaledFont(size: 11)
                            .foregroundStyle(Color.siriusMuted)
                    }
                    Spacer()
                    Text("\(result.total)%")
                        .scaledFont(size: 24, weight: .semibold)
                        .foregroundStyle(color(for: result.tier))
                }
                
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.siriusBarTrack)
                        Capsule()
                            .fill(color(for: result.tier))
                            .frame(width: proxy.size.width * CGFloat(result.total) / 100)
                        Rectangle()
                            .fill(Color.siriusInk)
                            .frame(width: 2, height: 18)
                            .offset(x: proxy.size.width * CGFloat(MatchRules.autoApplyThreshold) / 100)
                    }
                }
                .frame(height: 18)
                .padding(.top, 10)
            }
        }
        .padding(20)
        .fluidFrame(width: 370, alignment: .leading)
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    // Location (shown, not scored), resume and the scheduled interview
    private func extrasCard(_ applicant: EmpApplicant) -> some View {
        let interview = aplController.interview(for: applicant)
        return VStack(alignment: .leading, spacing: 10) {
            extraRow("mappin.and.ellipse", "Location",
                     applicant.location.isEmpty ? "Not provided" : applicant.location,
                     note: locationNote(applicant))
            extraRow("doc.text", "Resume",
                     applicant.resumeFileName.isEmpty ? "No resume uploaded" : applicant.resumeFileName,
                     note: nil)
            if applicant.status == .interview, let interview {
                Divider()
                extraRow("calendar", "Interview",
                         interview.date.formatted(date: .abbreviated, time: .shortened) + " \u{00B7} " + interview.location,
                         note: interview.message.isEmpty ? nil : interview.message)
            }
        }
        .padding(20)
        .frame(maxWidth: 370, alignment: .leading)
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func locationNote(_ applicant: EmpApplicant) -> String? {
        guard let matches = applicant.breakdown?.locationMatches else { return nil }
        return matches ? "In the preferred area" : "Outside the preferred area (not part of the score)"
    }
    
    private func extraRow(_ icon: String, _ title: String, _ value: String, note: String?) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Color.siriusAction)
                .frame(width: 20)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).scaledFont(size: 12).foregroundStyle(Color.siriusMuted)
                Text(value).scaledFont(size: 14, weight: .semibold).foregroundStyle(Color.siriusInk)
                if let note {
                    Text(note).scaledFont(size: 11).foregroundStyle(Color.siriusMuted)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
    
    private func scoreRow(_ title: String, _ points: Int, _ outOf: Int, _ caption: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                    .scaledFont(size: 14, weight: .semibold)
                    .foregroundStyle(Color.siriusInk)
                Spacer()
                Text("\(points) / \(outOf)")
                    .scaledFont(size: 14, weight: .semibold)
                    .foregroundStyle(points == outOf ? Color.siriusMatchBar : Color.siriusInk)
            }
            Text(caption)
                .scaledFont(size: 11)
                .foregroundStyle(Color.siriusMuted)
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
                SiriusButton(title: "Reschedule Interview", isFilled: false) {
                    aplController.beginRescheduling(applicant)
                    dismiss()                       // the dialog opens on the applicants list
                }
            }
            SiriusButton(title: "Reject Applicant", isFilled: false) {
                showReject = true
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
