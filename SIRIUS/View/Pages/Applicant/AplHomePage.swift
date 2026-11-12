//
//  AplHomePage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct AplHomePage: View {
    
    @Binding var selectedTab: AplNavigationTab
    
    @EnvironmentObject private var applicantController: AplInfoController
    @EnvironmentObject private var jobsController: AplJobsController
    @EnvironmentObject private var controller: AplApplicationsController
    
    @State private var isApplying = false
    @State private var showResult = false
    @State private var resultTitle = ""
    @State private var resultMessage = ""
    @State private var selectedApplicationID: UUID?
    
    private var firstName: String {
        let name = applicantController.applicant.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "there" : name
    }
    
    // Interviews that have not happened yet, soonest first
    private var upcomingInterviews: [JobApplication] {
        let now = Date()
        return controller.allApplications
            .filter { $0.status == .interview && ($0.interview?.date ?? .distantPast) >= now }
            .sorted { ($0.interview?.date ?? .distantFuture) < ($1.interview?.date ?? .distantFuture) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Greetings,")
                            .scaledFont(size: 20, weight: .light)
                        Text("\(firstName)!")
                            .scaledFont(size: 25, weight: .medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(Color.white)
                    
                    Spacer(minLength: 8)
                    
                    NotificationBell()
                }
                .padding(.leading, 45)
                .padding(.trailing, 32)
                .padding(.top, 75)
                
                QualiMatchCard(
                    percentage: "\(jobsController.averageMatch)%",
                    title: "Average Qualification Match",
                    subtext: matchSubtext
                )
                .padding(.leading, 19)
                .padding(.top, 25)
                
                quickActions
                    .padding(.leading, 19)
                    .padding(.top, 20)
                
                topMatch
                    .padding(.leading, 19)
                    .padding(.top, 29)
                
                applicationStatus
                    .padding(.leading, 32)
                    .padding(.top, 25)
                
                upcomingInterviewsSection
                    .padding(.leading, 19)
                    .padding(.top, 25)
                
                recentActivitySection
                    .padding(.leading, 19)
                    .padding(.top, 25)
                    .padding(.bottom, NavBarMetrics.clearance + 28)          // room for the bottom bar
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .ignoresSafeArea(.container, edges: .top)
        .refreshable { await JobBoard.shared.reload(silent: true) }
        .appBg()
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $selectedApplicationID) { id in
            // Pass the objects in: tab pages live in a TabView, so SwiftUI hosts this page outside the
            // tab's environment and it would not find them otherwise (crash: "No ObservableObject ... found")
            ApplicationDetailsPage(applicationID: id)
                .environmentObject(controller)
        }
        .alert(resultTitle, isPresented: $showResult) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(resultMessage)
        }
    }
    
    private var matchSubtext: String {
        let matched = jobsController.matchedListings
        let applied = matched.filter { $0.hasApplied }.count
        return "\(matched.count) green match\(matched.count == 1 ? "" : "es") \u{00B7} \(applied) applied"
    }
    
    // MARK: - Quick actions (Auto-Apply)
    
    // Small "Quick Action" bar. Auto-Apply sends applications to up to 10 green-match jobs
    // that the applicant has not applied to yet; the database notifies the applicant and the employers.
    private var quickActions: some View {
        HStack(spacing: 12) {
            Text("Quick Action")
                .scaledFont(size: 15, weight: .medium)
                .foregroundStyle(Color.siriusText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer(minLength: 8)
            
            Button {
                runAutoApply()
            } label: {
                HStack(spacing: 6) {
                    if isApplying {
                        ProgressView()
                            .tint(Color.white)
                            .controlSize(.small)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .scaledFont(size: 13)
                    }
                    Text("Auto-Apply")
                        .scaledFont(size: 12, weight: .bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(Color.white)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.siriusNavy))
                .shadow(color: Color.black.opacity(0.35), radius: 2, x: 1, y: 2)
            }
            .disabled(isApplying)
            .accessibilityLabel("Auto-Apply")
            .accessibilityHint("Applies to up to \(JobBoard.applyBatchSize) jobs that match you in the green")
        }
        .padding(.horizontal, 15)
        .fluidFrame(width: 360, height: 50)
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 4)
    }
    
    private func runAutoApply() {
        guard !isApplying else { return }
        isApplying = true
        Task {
            let outcome = await jobsController.applyToMore()      // re-checks the latest jobs first
            isApplying = false
            
            if outcome.failed {
                resultTitle = "Couldn't apply"
                resultMessage = "Check your internet connection and try again."
            } else if outcome.applied.isEmpty {
                // Nothing new matches: shown every time until a new green-match job is posted
                resultTitle = "No available jobs yet"
                resultMessage = "There are no new jobs that match your profile in the green (\(MatchRules.greenMinimum)% or more) right now. Check again later."
            } else {
                resultTitle = "Auto-Apply complete"
                let lines = outcome.applied.map { "\u{2022} \($0.position), \($0.company) (\($0.percentage)%)" }
                resultMessage = lines.joined(separator: "\n") + "\n\nThe employers were notified."
            }
            showResult = true
        }
    }
    
    // MARK: - Top match
    
    // "Top Match For You" panel (#03527b, radius 10, 15pt padding)
    private var topMatch: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Top Match For You")
                .scaledFont(size: 15, weight: .medium)
                .foregroundStyle(Color.white)
            
            if let top = jobsController.topListing {
                Button {
                    selectedTab = .jobs
                } label: {
                    AplJobCard(
                        jobTitle: top.job.jobPos,
                        companyName: top.job.companyName.isEmpty ? "Company" : top.job.companyName,
                        jobLocation: top.job.requiredLoc.isEmpty ? top.job.workSetup.rawValue : top.job.requiredLoc,
                        jobSalary: top.job.salary > 0 ? "\(top.job.salaryText) / month" : "",
                        matchPrct: Double(top.percentage),
                        width: 333,
                        isAutoApplied: top.hasApplied
                    )
                }
                .buttonStyle(.plain)
            } else {
                Text("No matching jobs yet. Jobs in the green (\(MatchRules.greenMinimum)% or more) appear here.")
                    .scaledFont(size: 11)
                    .foregroundStyle(.white.opacity(0.85))
                    .fluidFrame(width: 333, height: 88)
            }
        }
        .padding(15)
        .background(Color.siriusPanel)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.25), radius: 5)
    }
    
    // MARK: - Application status
    
    // "Application Status" label + Applied | Interview | Accepted counts
    private var applicationStatus: some View {
        HStack {
            Text("Application Status")
                .scaledFont(size: 15, weight: .semibold)
                .foregroundStyle(Color.siriusText)
                .frame(width: 81, alignment: .leading)
            
            Spacer()
            
            HStack(spacing: 0) {
                statusCell(count: controller.allApplications.count, label: "Applied")
                Rectangle().fill(Color.black).frame(width: 0.5)
                statusCell(count: controller.count(of: .interview), label: "Interview")
                Rectangle().fill(Color.black).frame(width: 0.5)
                statusCell(count: controller.count(of: .accepted), label: "Accepted")
            }
            .frame(height: 53)
            .background(Color.siriusSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.25), radius: 2)
        }
        .fluidFrame(width: 333)
    }
    
    private func statusCell(count: Int, label: String) -> some View {
        VStack(spacing: 3) {
            Text("\(count)")
                .scaledFont(size: 15, weight: .bold)
            Text(label)
                .scaledFont(size: 8)
        }
        .foregroundStyle(Color.siriusText)
        .frame(width: 81, height: 53)
    }
    
    // MARK: - Panels
    
    // Same navy container as "Top Match For You"
    private func panel<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .scaledFont(size: 15, weight: .medium)
                .foregroundStyle(Color.white)
            content()
        }
        .padding(15)
        .background(Color.siriusPanel)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.25), radius: 5)
    }
    
    private func panelNote(_ text: String) -> some View {
        Text(text)
            .scaledFont(size: 11)
            .foregroundStyle(Color.white.opacity(0.85))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .fluidFrame(width: 333, height: 60)
    }
    
    // Which job, which company, when and where. Tap a card for the full details.
    private var upcomingInterviewsSection: some View {
        panel("Upcoming Interviews") {
            if upcomingInterviews.isEmpty {
                panelNote("No interviews scheduled yet. When an employer schedules one, it shows up here.")
            } else {
                VStack(spacing: 12) {
                    ForEach(upcomingInterviews.prefix(3)) { app in
                        if let interview = app.interview {
                            Button {
                                selectedApplicationID = app.id
                            } label: {
                                InterviewScheduleCard(
                                    role: app.role,
                                    company: app.company,
                                    interview: interview,
                                    showsNewBadge: controller.hasNewInterview(app)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
    
    // The five newest applications. Tap a card for its details.
    private var recentActivitySection: some View {
        panel("Recent Activity") {
            if controller.allApplications.isEmpty {
                panelNote("No applications yet. Tap Auto-Apply in Quick Action to apply to the jobs that match you in the green (\(MatchRules.greenMinimum)% or more).")
            } else {
                VStack(spacing: 12) {
                    ForEach(controller.allApplications.prefix(5)) { app in
                        Button {
                            selectedApplicationID = app.id
                        } label: {
                            JobApplicationCard(application: app, showsNewBadge: controller.hasNewInterview(app))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview{
    AplHomePage(selectedTab: .constant(.home))
        .environmentObject(AplInfoController(applicant: AplInfoController.blankApplicant()))
        .environmentObject(AplJobsController(
            info: AplInfoController(applicant: AplInfoController.blankApplicant()),
            board: JobBoard()
        ))
        .environmentObject(AplApplicationsController(board: JobBoard()))
}
