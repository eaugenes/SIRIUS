//
//  EmpApplicantsOverviewPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct EmpApplicantsOverviewPage: View {
    
    @EnvironmentObject private var jobController: EmpJobController
    @EnvironmentObject private var aplController: EmpAplStatusController
    
    @State private var selectedJob: Job?
    
    // Only active jobs appear here
    private var activeJobs: [Job] {
        jobController.jobs.filter { $0.isActive }
    }
    
    private var totalApplicants: Int {
        aplController.totalApplicants(inJobs: Set(activeJobs.map { $0.jobID }))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Manage Applicants")
                .scaledFont(size: 30, weight: .medium)
                .foregroundStyle(Color.white)
                .padding(.horizontal, 32)
                .padding(.top, 20)
                .padding(.bottom, 16)
            
            summary
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
            
            if activeJobs.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(activeJobs) { job in
                            Button {
                                selectedJob = job
                            } label: {
                                jobRow(job)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 100)          // room for the bottom bar
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBg()
        .boardLoadState()
        .navigationDestination(item: $selectedJob) { job in
            EmpManageApplicantsPage(job: job)
        }
    }
    
    // [ active jobs | total applicants ]
    private var summary: some View {
        HStack(spacing: 0) {
            summaryCell(value: activeJobs.count, title: "Active Jobs")
            
            Divider()
                .frame(height: 40)
            
            summaryCell(value: totalApplicants, title: "Total Applicants")
        }
        .frame(maxWidth: .infinity)
        .frame(height: 76)
        .background(Color.siriusSurface)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
    
    private func summaryCell(value: Int, title: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .scaledFont(size: 26, weight: .semibold)
                .foregroundStyle(Color.siriusInk)
            Text(title)
                .scaledFont(size: 11)
                .foregroundStyle(Color.siriusTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func jobRow(_ job: Job) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(job.jobPos)
                    .scaledFont(size: 13, weight: .medium)
                    .foregroundStyle(Color.siriusText)
                    .lineLimit(1)
                
                Text("Review - \(aplController.count(forJobID: job.jobID, status: .toReview)) | Interview - \(aplController.count(forJobID: job.jobID, status: .interview)) | Hired - \(aplController.count(forJobID: job.jobID, status: .hired))")
                    .scaledFont(size: 10)
                    .foregroundStyle(Color.siriusTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer()
            
            Image(systemName: "chevron.forward")
                .scaledFont(size: 20)
                .foregroundStyle(Color.siriusText)
        }
        .padding(.horizontal, 16)
        .fluidFrame(width: 338, height: 65)
        .background(Color.siriusSurface)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 4, y: 4)
        .contentShape(Rectangle())
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2")
                .scaledFont(size: 32)
            Text("No active jobs")
                .scaledFont(size: 15, weight: .medium)
            Text("Post a job to start receiving matched applicants.")
                .scaledFont(size: 12, weight: .light)
        }
        .foregroundStyle(Color.siriusInk)
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    NavigationStack {
        EmpApplicantsOverviewPage()
            .environmentObject(EmpJobController(jobs: EmpJobController.sampleJobs))
            .environmentObject(EmpAplStatusController(applicants: EmpAplStatusController.sampleApplicants))
    }
}
