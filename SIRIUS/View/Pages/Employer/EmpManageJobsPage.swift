//
//  EmpManageJobsPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/13/26.
//

import SwiftUI

// Employer "Manage Jobs" tab with Active / Inactive lists
// (Figma: Manage Jobs (Employer) — Active and Inactive variants)
struct EmpManageJobsPage: View {
    
    @EnvironmentObject private var jobController: EmpJobController
    
    @State private var selectedJobID: String?       // pushes that job's details
    @State private var jobPostingScreen = false
    @State private var jobToDelete: Job?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Manage Jobs")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Button {
                    jobPostingScreen = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.siriusNavy)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white))
                }
                .accessibilityLabel("Post a job")
            }
            .padding(.horizontal, 32)
            .padding(.top, 20)
            .padding(.bottom, 14)
            
            EmployerSegmentedTabs(
                items: JobListTab.allCases,
                title: { $0.rawValue },
                selection: $jobController.selectedTab
            )
            .frame(maxWidth: .infinity)
            .padding(.bottom, 28)
            
            if jobController.filteredJobs.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(jobController.filteredJobs) { job in
                            Button {
                                selectedJobID = job.jobID
                            } label: {
                                EmpJobCard(job: job)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    withAnimation { jobController.toggleStatus(of: job) }
                                } label: {
                                    if job.isActive {
                                        Label("Mark as Inactive", systemImage: "pause.circle")
                                    } else {
                                        Label("Mark as Active", systemImage: "play.circle")
                                    }
                                }
                                
                                Button(role: .destructive) {
                                    jobToDelete = job
                                } label: {
                                    Label("Delete Job", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                    .padding(.bottom, 100)          // room for the bottom bar
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBg()
        .navigationDestination(item: $selectedJobID) { jobID in
            EmpJobDetailsPage(jobID: jobID)
        }
        .navigationDestination(isPresented: $jobPostingScreen) {
            EmpJobPostingPage()
        }
        .alert(
            "Delete this job?",
            isPresented: Binding(
                get: { jobToDelete != nil },
                set: { if !$0 { jobToDelete = nil } }
            ),
            presenting: jobToDelete
        ) { job in
            Button("Delete", role: .destructive) {
                withAnimation { jobController.deleteJob(job) }
                jobToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                jobToDelete = nil
            }
        } message: { job in
            Text("\"\(job.jobPos)\" will be removed from your job list.")
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "briefcase")
                .font(.system(size: 32))
            Text(jobController.selectedTab == .active ? "No active jobs yet" : "No inactive jobs")
                .font(.system(size: 15, weight: .medium))
            if jobController.selectedTab == .active {
                Text("Tap + to post a job opening.")
                    .font(.system(size: 12, weight: .light))
            }
        }
        .foregroundStyle(Color.siriusNavy)
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

#Preview {
    NavigationStack {
        EmpManageJobsPage()
            .environmentObject(EmpInfoController.sample())
            .environmentObject(EmpJobController(jobs: EmpJobController.sampleJobs))
            .environmentObject(EmpAplStatusController(applicants: EmpAplStatusController.sampleApplicants))
    }
}
