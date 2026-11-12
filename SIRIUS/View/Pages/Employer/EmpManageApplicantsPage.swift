//
//  EmpManageApplicantsPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/13/26.
//

import SwiftUI

struct EmpManageApplicantsPage: View {
    
    var job: Job? = nil
    
    @EnvironmentObject private var aplController: EmpAplStatusController
    @Environment(\.dismiss) private var dismiss
    @State private var applicantToReject: EmpApplicant?
    @State private var openedApplicantID: UUID?
    
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
                .padding(.bottom, 8)
                
                filterBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                
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
                                    onRemove: { applicantToReject = applicant },
                                    onOpen: { openedApplicantID = applicant.id },
                                    onHire: { withAnimation { aplController.hire(applicant) } },
                                    onReschedule: { aplController.beginRescheduling(applicant) }
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, job == nil ? NavBarMetrics.clearance + 8 : 30)     // room for the bottom bar
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .animation(.easeInOut(duration: 0.2), value: aplController.selectedFilter)
        }
        .appBg()
        .scheduleInterviewOverlay(aplController)         // Schedule / Reschedule Interview dialog
        .navigationBarBackButtonHidden(true)
        .hidesSiriusNavBar(job != nil)                   // pushed from Manage Jobs: no bottom bar over the list
        .onDisappear { aplController.clearSelection() }
        .boardLoadState()
        .navigationDestination(item: $openedApplicantID) { id in
            // Pass the objects in: tab pages live in a TabView, so SwiftUI hosts this page outside the
            // tab's environment and it would not find them otherwise (crash: "No ObservableObject ... found")
            EmpAplDetailsPage(applicantID: id)
                .environmentObject(aplController)
        }
        .sheet(item: $applicantToReject) { applicant in
            RejectApplicantDialog(
                applicantName: applicant.name,
                onReject: { reason in
                    withAnimation { aplController.removeApplicant(applicant, reason: reason) }
                    applicantToReject = nil
                },
                onCancel: { applicantToReject = nil }
            )
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
    
    // Search + sort + minimum-match filter
    private var filterBar: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.siriusMuted)
                    .accessibilityHidden(true)
                TextField("", text: $aplController.searchText,
                          prompt: Text("Search name, program or language").foregroundColor(Color.siriusMuted))
                    .scaledFont(size: 13)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityLabel("Search applicants")
                if !aplController.searchText.isEmpty {
                    Button {
                        aplController.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(Color.siriusMuted)
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(Capsule().fill(Color.siriusSurface))
            
            Menu {
                Picker("Sort by", selection: $aplController.sortOption) {
                    ForEach(EmpApplicantSort.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Match", selection: $aplController.matchFilter) {
                    ForEach(EmpMatchFilter.allCases) { Text($0.rawValue).tag($0) }
                }
                if aplController.hasActiveFilters {
                    Button("Reset", role: .destructive) { aplController.resetFilters() }
                }
            } label: {
                Image(systemName: aplController.hasActiveFilters
                      ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .scaledFont(size: 24)
                    .foregroundStyle(Color.white)
                    .frame(width: 38, height: 38)
            }
            .accessibilityLabel("Sort and filter applicants")
            .accessibilityValue("\(aplController.sortOption.rawValue), \(aplController.matchFilter.rawValue)")
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
                            .scaledFont(size: 24)
                            .foregroundStyle(Color.white)
                            .frame(width: 30, height: 44, alignment: .leading)
                    }
                    .accessibilityLabel("Back")
                    
                    Text("Manage Applicants")
                        .scaledFont(size: 30, weight: .medium)
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                Text(job.jobPos)
                    .scaledFont(size: 14, weight: .light)
                    .foregroundStyle(Color.white)
                    .padding(.leading, 38)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        } else {
            Text("Manage Applicants")
                .scaledFont(size: 30, weight: .medium)
                .foregroundStyle(Color.white)
                .padding(.horizontal, 32)
                .padding(.top, 20)
        }
    }
    
    private var emptyState: some View {
        Group {
            if aplController.hasActiveFilters {
                EmptyStateView(
                    icon: "line.3.horizontal.decrease.circle",
                    title: "No applicants match your filters",
                    message: "Try a different search or lower the minimum match.",
                    actionTitle: "Reset filters",
                    action: { aplController.resetFilters() }
                )
            } else {
                EmptyStateView(
                    icon: "person.2",
                    title: "No applicants here yet",
                    message: "Applicants who match in the green (\(MatchRules.greenMinimum)% or more) are added automatically."
                )
            }
        }
        .padding(.top, 70)
    }
}

#Preview {
    NavigationStack {
        EmpManageApplicantsPage()
            .environmentObject(EmpAplStatusController())
    }
}
