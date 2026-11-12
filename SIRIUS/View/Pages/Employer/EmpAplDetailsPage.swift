//
//  EmpAplDetailsPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct EmpAplDetailsPage: View {
    
    let applicantID: UUID
    
    @EnvironmentObject private var aplController: EmpAplStatusController
    @Environment(\.dismiss) private var dismiss
    
    @State private var showReject = false
    @State private var projects: [Project] = []
    
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
        .scheduleInterviewOverlay(aplController)         // the Schedule Interview dialog opens right here
        .navigationBarBackButtonHidden(true)
        .hidesSiriusNavBar()
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
        .task(id: applicant?.applicantID) {
            guard let id = applicant?.applicantID else { return }
            projects = await SupabaseStore.fetchProjects(applicantID: id)
        }
    }
    
    private func content(for applicant: EmpApplicant) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 14) {
                CircleBackButton { dismiss() }
                Text("Applicant Details")
                    .scaledFont(size: 24, weight: .medium)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
            
            ScrollView {
                VStack(spacing: 14) {
                    mainCard(applicant)
                    detailsCard(applicant)
                    projectsCard
                    FormErrorText(message: aplController.actionError)
                    actions(applicant)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    // MARK: - Profile + compatibility
    
    // White card: profile, compatibility banner and rows, language chips, overall match
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
                .lineLimit(2)
                .minimumScaleFactor(0.7)
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
            
            // Blue-to-green gradient: the greener it is, the more compatible the applicant is
            CompatibilityBanner(percentage: result?.total ?? applicant.matchPercentage)
            
            if let result {
                VStack(alignment: .leading, spacing: 12) {
                    scoreRow("Program", result.program, Int(MatchRules.programPoints), programs.isEmpty ? "Required: Any program" : "Required: \(programs)")
                    scoreRow("Work experience", result.experience, Int(MatchRules.experiencePoints), "Required: \(yearsText)")
                    scoreRow("Programming languages", result.languages, Int(MatchRules.languagePoints), langs.isEmpty ? "Required: Any" : "Required: \(langs)")
                    scoreRow("Work setup", result.workSetup, Int(MatchRules.workSetupPoints), applicant.jobWorkSetup.isEmpty ? "Required: Any" : "Required: \(applicant.jobWorkSetup) (applicant prefers \(applicant.workSetup.isEmpty ? "none" : applicant.workSetup))")
                }
                .padding(.top, 14)
                
                // Language chips wrap onto more lines instead of running off the card
                FlowLayout(spacing: 6) {
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
                        Text("Auto-apply minimum: \(MatchRules.autoApplyThreshold)% match")
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
    
    // MARK: - Applicant details
    
    // Program, experience, work setup, location (shown, not scored), contact details and the interview
    private func detailsCard(_ applicant: EmpApplicant) -> some View {
        let interview = aplController.interview(for: applicant)
        return VStack(alignment: .leading, spacing: 12) {
            Text("Applicant Details")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusAction)
            
            detailRow("graduationcap", "Program", applicant.degree)
            detailRow("briefcase", "Work experience", applicant.experienceText.replacingOccurrences(of: " work experience", with: ""))
            detailRow("desktopcomputer", "Work setup", applicant.workSetup)
            detailRow("mappin.and.ellipse", "Location", applicant.location, note: locationNote(applicant))
            
            Divider()
            
            detailRow("phone", "Contact number", applicant.contactNumber, selectable: true)
            detailRow("envelope", "Email", applicant.email, selectable: true)
            
            if applicant.status != .toReview, let interview {
                Divider()
                detailRow("calendar", "Interview",
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
    
    private func detailRow(_ icon: String, _ title: String, _ value: String, note: String? = nil, selectable: Bool = false) -> some View {
        let shown = value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not provided" : value
        return HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Color.siriusAction)
                .frame(width: 20)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).scaledFont(size: 12).foregroundStyle(Color.siriusMuted)
                if selectable {
                    Text(shown)
                        .scaledFont(size: 14, weight: .semibold)
                        .foregroundStyle(Color.siriusInk)
                        .textSelection(.enabled)
                } else {
                    Text(shown)
                        .scaledFont(size: 14, weight: .semibold)
                        .foregroundStyle(Color.siriusInk)
                }
                if let note {
                    Text(note).scaledFont(size: 11).foregroundStyle(Color.siriusMuted)
                }
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Projects
    
    // The applicant's projects (title, description, pictures); replaces the old resume row
    private var projectsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Projects")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusAction)
            ProjectsSection(projects: projects, emptyText: "This applicant has not added any projects.")
        }
        .padding(20)
        .frame(maxWidth: 370, alignment: .leading)
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
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
    
    // MARK: - Actions
    
    @ViewBuilder
    private func actions(_ applicant: EmpApplicant) -> some View {
        VStack(spacing: 10) {
            if applicant.status == .toReview {
                SiriusButton(title: "Schedule Interview") {
                    aplController.beginScheduling(applicant)        // opens the dialog on this page
                }
            }
            if applicant.status == .interview {
                SiriusButton(title: "Hire") {
                    aplController.hire(applicant)
                }
                SiriusButton(title: "Reschedule Interview", isFilled: false) {
                    aplController.beginRescheduling(applicant)
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

// Simple wrapping row (chips that do not fit move to the next line)
struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widest: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            widest = max(widest, x - spacing)
        }
        return CGSize(width: proposal.width ?? widest, height: y + rowHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
