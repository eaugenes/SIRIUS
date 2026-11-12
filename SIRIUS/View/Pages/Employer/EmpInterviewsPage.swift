//
//  EmpInterviewsPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI

// Employer "Interviews": tracks every interview of the company's applicants.
//   Upcoming  - the interview time has not come yet
//   Awaiting  - the interview time passed and the applicant is still waiting for a decision
//   Hired     - the applicant was hired after the interview
// Tap an interview for its details (date, time, place, message) and to hire, reschedule or reject.
struct EmpInterviewsPage: View {
    
    @EnvironmentObject private var aplController: EmpAplStatusController
    @Environment(\.dismiss) private var dismiss
    
    @State private var filter: EmpInterviewFilter = .upcoming
    @State private var openedApplicantID: UUID?
    
    private var items: [EmpInterviewItem] {
        aplController.interviewItems(for: filter)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.bottom, 14)
            
            summary
                .padding(.horizontal, 32)
                .padding(.bottom, 14)
            
            EmployerSegmentedTabs(
                items: EmpInterviewFilter.allCases,
                title: { $0.rawValue },
                selection: $filter
            )
            .frame(maxWidth: .infinity)
            .padding(.bottom, 14)
            
            if items.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(items) { item in
                            Button {
                                openedApplicantID = item.applicant.id
                            } label: {
                                EmpInterviewCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.easeInOut(duration: 0.2), value: filter)
        .appBg()
        .navigationBarBackButtonHidden(true)
        .hidesSiriusNavBar()
        .boardLoadState()
        .navigationDestination(item: $openedApplicantID) { id in
            EmpInterviewDetailsPage(applicantID: id)
                .environmentObject(aplController)
        }
    }
    
    private var header: some View {
        HStack(spacing: 8) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .scaledFont(size: 24)
                    .foregroundStyle(Color.white)
                    .frame(width: 30, height: 44, alignment: .leading)
            }
            .accessibilityLabel("Back")
            
            Text("Interviews")
                .scaledFont(size: 30, weight: .medium)
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
    
    // [ upcoming | awaiting decision | hired ]
    private var summary: some View {
        HStack(spacing: 0) {
            summaryCell(value: aplController.upcomingInterviewCount, title: "Upcoming")
            Divider().frame(height: 36)
            summaryCell(value: aplController.awaitingDecisionCount, title: "Awaiting")
            Divider().frame(height: 36)
            summaryCell(value: aplController.interviewItems.filter { $0.state == .hired }.count, title: "Hired")
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(Color.siriusSurface)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
    
    private func summaryCell(value: Int, title: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .scaledFont(size: 24, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
            Text(title)
                .scaledFont(size: 11)
                .foregroundStyle(Color.siriusTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emptyState: some View {
        let message: String
        switch filter {
        case .upcoming: message = "Schedule an interview from Manage Applicants and it will show up here."
        case .awaiting: message = "Interviews that already happened and still need a decision appear here."
        case .hired: message = "Applicants you hire after an interview appear here."
        }
        return EmptyStateView(icon: "calendar", title: "No \(filter.rawValue.lowercased()) interviews", message: message)
            .padding(.top, 60)
    }
}

// One interview row: applicant, job, when and where, plus its status
struct EmpInterviewCard: View {
    
    let item: EmpInterviewItem
    
    private var stateColor: Color {
        switch item.state {
        case .upcoming: return Color.siriusPanel
        case .awaitingDecision: return Color.siriusMatchOrange
        case .hired: return Color.siriusMatchBar
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 0) {
                Text(item.interview.date.formatted(.dateTime.month(.abbreviated)).uppercased())
                    .scaledFont(size: 10, weight: .bold)
                Text(item.interview.date.formatted(.dateTime.day()))
                    .scaledFont(size: 20, weight: .bold)
            }
            .foregroundStyle(Color.white)
            .frame(width: 48, height: 52)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.siriusNavy))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.applicant.name)
                    .scaledFont(size: 13, weight: .medium)
                    .foregroundStyle(Color.siriusText)
                    .lineLimit(1)
                Text(item.applicant.jobPosition)
                    .scaledFont(size: 10)
                    .foregroundStyle(Color.siriusText)
                    .lineLimit(1)
                Text(item.interview.date.formatted(date: .omitted, time: .shortened) + " \u{00B7} " + item.interview.location)
                    .scaledFont(size: 10, weight: .light)
                    .foregroundStyle(Color.siriusText)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 4)
            
            Text(item.state.label)
                .scaledFont(size: 8, weight: .bold)
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 76, height: 20)
                .background(RoundedRectangle(cornerRadius: 15).fill(stateColor))
        }
        .padding(.horizontal, 12)
        .frame(width: 354, height: 74)
        .background(Color.siriusSurface)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.applicant.name), \(item.applicant.jobPosition), \(item.interview.date.formatted(date: .complete, time: .shortened)), \(item.interview.location), \(item.state.label)")
        .accessibilityHint("Opens interview details")
        .accessibilityAddTraits(.isButton)
    }
}

// Details of one interview
struct EmpInterviewDetailsPage: View {
    
    let applicantID: UUID
    
    @EnvironmentObject private var aplController: EmpAplStatusController
    @Environment(\.dismiss) private var dismiss
    
    @State private var showReject = false
    @State private var openedApplicantID: UUID?
    
    private var item: EmpInterviewItem? {
        aplController.interviewItem(forApplicant: applicantID)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let item {
                content(for: item)
            } else {
                VStack(spacing: 12) {
                    Text("This interview is no longer available.")
                        .scaledFont(size: 14, weight: .medium)
                        .foregroundStyle(Color.siriusInk)
                    SiriusButton(title: "Back") { dismiss() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .appBg()
        .scheduleInterviewOverlay(aplController)         // Reschedule Interview dialog
        .navigationBarBackButtonHidden(true)
        .hidesSiriusNavBar()
        .navigationDestination(item: $openedApplicantID) { id in
            EmpAplDetailsPage(applicantID: id)
                .environmentObject(aplController)
        }
        .sheet(isPresented: $showReject) {
            if let item {
                RejectApplicantDialog(
                    applicantName: item.applicant.name,
                    onReject: { reason in
                        aplController.removeApplicant(item.applicant, reason: reason)
                        showReject = false
                        dismiss()
                    },
                    onCancel: { showReject = false }
                )
            }
        }
        .alert("Couldn't complete that", isPresented: Binding(
            get: { aplController.actionError != nil },
            set: { if !$0 { aplController.actionError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(aplController.actionError ?? "")
        }
    }
    
    private func content(for item: EmpInterviewItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                CircleBackButton { dismiss() }
                Text("Interview Details")
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
                    applicantCard(item)
                    scheduleCard(item.interview)
                    actions(item)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private func applicantCard(_ item: EmpInterviewItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(item.applicant.name)
                    .scaledFont(size: 22, weight: .semibold)
                    .foregroundStyle(Color.siriusInk)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 8)
                MatchPill(percentage: item.applicant.matchPercentage)
            }
            Text(item.applicant.degree)
                .scaledFont(size: 14)
                .foregroundStyle(Color.siriusMuted)
            Text(item.applicant.experienceText)
                .scaledFont(size: 14)
                .foregroundStyle(Color.siriusMuted)
            
            Divider().padding(.vertical, 8)
            
            line("Applied to", item.applicant.jobPosition)
            line("Status", item.state.label)
        }
        .padding(20)
        .frame(maxWidth: 370, alignment: .leading)
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func scheduleCard(_ interview: Interview) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Interview", systemImage: "calendar")
                .scaledFont(size: 16, weight: .semibold)
                .foregroundStyle(Color.siriusAction)
            
            line("Date", interview.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
            line("Time", interview.date.formatted(date: .omitted, time: .shortened))
            line("Place", interview.location)
            
            if !interview.message.isEmpty {
                Divider()
                Text("Message to the applicant")
                    .scaledFont(size: 12)
                    .foregroundStyle(Color.siriusMuted)
                Text(interview.message)
                    .scaledFont(size: 13)
                    .foregroundStyle(Color.siriusInk)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(20)
        .frame(maxWidth: 370, alignment: .leading)
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func line(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .scaledFont(size: 12)
                .foregroundStyle(Color.siriusMuted)
            Spacer(minLength: 12)
            Text(value)
                .scaledFont(size: 13, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
                .multilineTextAlignment(.trailing)
        }
    }
    
    @ViewBuilder
    private func actions(_ item: EmpInterviewItem) -> some View {
        VStack(spacing: 10) {
            SiriusButton(title: "View Applicant Details") {
                openedApplicantID = item.applicant.id
            }
            if item.state != .hired {
                SiriusButton(title: "Hire", isFilled: false) {
                    aplController.hire(item.applicant)
                }
                SiriusButton(title: "Reschedule Interview", isFilled: false) {
                    aplController.beginRescheduling(item.applicant)
                }
                SiriusButton(title: "Reject Applicant", isFilled: false) {
                    showReject = true
                }
            }
        }
    }
}
