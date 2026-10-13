//
//  EmpManageApplicantsPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/13/26.
//

import SwiftUI

// Employer "Manage Applicants" (Figma: Manage Applicants based on Job Position Opening — All / To Review / Interview / Hired)
// - As a tab (job == nil): every applicant.
// - Pushed from Manage Jobs (job != nil): only applicants for that job position, with a back button.
struct EmpManageApplicantsPage: View {
    
    var job: Job? = nil
    
    @EnvironmentObject private var aplController: EmpAplStatusController
    @Environment(\.dismiss) private var dismiss
    
    @State private var applicantToRemove: EmpApplicant?
    
    private var applicants: [EmpApplicant] {
        aplController.filteredApplicants(forPosition: job?.jobPos)
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.bottom, 12)
                
                EmployerSegmentedTabs(
                    items: EmpApplicantFilter.allCases,
                    title: { $0.rawValue },
                    selection: $aplController.selectedFilter
                )
                .frame(maxWidth: .infinity)
                .padding(.bottom, 12)
                
                if applicants.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(applicants) { applicant in
                                EmpAplCard(
                                    applicant: applicant,
                                    isSelected: aplController.isSelected(applicant),
                                    onSelect: { aplController.toggleSelection(applicant) },
                                    onSchedule: { aplController.beginScheduling(applicant) },
                                    onRemove: { applicantToRemove = applicant }
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, job == nil ? 100 : 30)     // room for the bottom bar
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .animation(.easeInOut(duration: 0.2), value: aplController.selectedFilter)
            
            // Schedule Interview modal
            if let target = aplController.interviewTarget {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { aplController.cancelScheduling() }
                    .transition(.opacity)
                
                ScheduleInterviewDialog(
                    applicantName: target.name,
                    onSend: { date, location, message in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            aplController.scheduleInterview(date: date, location: location, message: message)
                        }
                    },
                    onCancel: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            aplController.cancelScheduling()
                        }
                    }
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: aplController.interviewTarget?.id)
        .appBg()
        .navigationBarBackButtonHidden(true)
        .onDisappear { aplController.clearSelection() }
        .alert(
            "Remove applicant?",
            isPresented: Binding(
                get: { applicantToRemove != nil },
                set: { if !$0 { applicantToRemove = nil } }
            ),
            presenting: applicantToRemove
        ) { applicant in
            Button("Remove", role: .destructive) {
                withAnimation { aplController.removeApplicant(applicant) }
                applicantToRemove = nil
            }
            Button("Cancel", role: .cancel) {
                applicantToRemove = nil
            }
        } message: { applicant in
            Text("\(applicant.name) will be removed from your applicants.")
        }
    }
    
    @ViewBuilder
    private var header: some View {
        if let job {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.white)
                            .frame(width: 30, height: 44, alignment: .leading)
                    }
                    .accessibilityLabel("Back")
                    
                    Text("Manage Applicants")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                Text(job.jobPos)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color.white)
                    .padding(.leading, 38)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        } else {
            Text("Manage Applicants")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 32)
                .padding(.top, 20)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2")
                .font(.system(size: 32))
            Text("No applicants here yet")
                .font(.system(size: 15, weight: .medium))
        }
        .foregroundStyle(Color.siriusNavy)
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

#Preview {
    NavigationStack {
        EmpManageApplicantsPage()
            .environmentObject(EmpAplStatusController())
    }
}
