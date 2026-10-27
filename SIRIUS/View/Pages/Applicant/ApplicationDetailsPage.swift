//
//  ApplicationDetailsPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

// One application: status, interview slot (date / place / message), the employer's
// rejection reason, why the applicant scored what they did, and Withdraw.
struct ApplicationDetailsPage: View {
    
    let applicationID: UUID
    
    @EnvironmentObject private var controller: AplApplicationsController
    @Environment(\.dismiss) private var dismiss
    
    @State private var confirmWithdraw = false
    
    private var application: JobApplication? {
        controller.allApplications.first { $0.id == applicationID }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 14) {
                    CircleBackButton { dismiss() }
                    Text("Application")
                        .scaledFont(size: 24, weight: .medium)
                        .foregroundStyle(Color.white)
                }
                .padding(.top, 12)
                
                if let application {
                    summaryCard(application)
                    
                    if let interview = application.interview, application.status == .interview {
                        interviewCard(interview)
                    }
                    if application.status == .rejected {
                        rejectionCard(application)
                    }
                    if let job = application.job, let profile = application.profile, let breakdown = application.breakdown {
                        panel {
                            MatchExplanationCard(job: job, profile: profile, breakdown: breakdown)
                        }
                    }
                    if application.canWithdraw {
                        Button {
                            confirmWithdraw = true
                        } label: {
                            Text("Withdraw Application")
                                .scaledFont(size: 16, weight: .semibold)
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.siriusDanger))
                        }
                        .padding(.top, 6)
                    }
                } else {
                    EmptyStateView(icon: "doc.questionmark", title: "This application is no longer available.")
                        .padding(.top, 60)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .appBg()
        .navigationBarBackButtonHidden(true)
        .alert("Withdraw this application?", isPresented: $confirmWithdraw) {
            Button("Withdraw", role: .destructive) {
                if let application { controller.withdraw(application) }
                dismiss()
            }
            Button("Keep", role: .cancel) {}
        } message: {
            Text("The employer will no longer see your application. You won't be applied to this job again automatically.")
        }
    }
    
    private func panel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) { content() }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.siriusSurface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func summaryCard(_ application: JobApplication) -> some View {
        panel {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(application.role)
                        .scaledFont(size: 20, weight: .semibold)
                        .foregroundStyle(Color.siriusInk)
                    Text(application.company)
                        .scaledFont(size: 13)
                        .foregroundStyle(Color.siriusMuted)
                    Text("Applied on \(application.dateApplied)")
                        .scaledFont(size: 11)
                        .foregroundStyle(Color.siriusMuted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    MatchPill(percentage: application.matchPercentage)
                    Text(application.status.rawValue)
                        .scaledFont(size: 10, weight: .bold)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 12)
                        .frame(height: 22)
                        .background(Capsule().fill(statusColor(application.status)))
                }
            }
            if let job = application.job {
                Divider()
                if job.salary > 0 { detail("Salary", "\(job.salaryText) / month") }
                detail("Location", job.requiredLoc.isEmpty ? "Any" : job.requiredLoc)
                detail("Work setup", job.workSetup.rawValue)
            }
        }
    }
    
    private func interviewCard(_ interview: Interview) -> some View {
        panel {
            Label("Your interview", systemImage: "calendar")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
            detail("Date", interview.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
            detail("Time", interview.date.formatted(date: .omitted, time: .shortened))
            detail("Place", interview.location)
            if !interview.message.isEmpty {
                Text(interview.message)
                    .scaledFont(size: 12)
                    .foregroundStyle(Color.siriusMuted)
                    .padding(.top, 2)
            }
        }
        .accessibilityElement(children: .combine)
    }
    
    private func rejectionCard(_ application: JobApplication) -> some View {
        panel {
            Label("Not selected", systemImage: "xmark.circle")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusDanger)
            Text(application.rejectionReason.isEmpty ? "The employer didn't share a reason." : application.rejectionReason)
                .scaledFont(size: 13)
                .foregroundStyle(Color.siriusMuted)
        }
        .accessibilityElement(children: .combine)
    }
    
    private func detail(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title).scaledFont(size: 12).foregroundStyle(Color.siriusMuted)
            Spacer()
            Text(value)
                .scaledFont(size: 13, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private func statusColor(_ status: ApplicationStatus) -> Color {
        switch status {
        case .accepted: return Color.siriusMatchBar
        case .rejected: return Color.siriusDanger
        case .withdrawn: return Color.siriusMuted
        default: return Color.siriusPanel
        }
    }
}
