//
//  AplHomePage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

// Figma "Final" Home Screen (Applicant)
struct AplHomePage: View {
    
    @Binding var selectedTab: AplNavigationTab
    
    @EnvironmentObject private var applicantController: AplInfoController
    @EnvironmentObject private var jobsController: AplJobsController
    @EnvironmentObject private var controller: AplApplicationsController
    
    private var firstName: String {
        let name = applicantController.applicant.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "there" : name
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Greetings
                VStack(alignment: .leading, spacing: 0) {
                    Text("Greetings,")
                        .scaledFont(size: 20, weight: .light)
                    Text("\(firstName)!")
                        .scaledFont(size: 25, weight: .medium)
                }
                .foregroundStyle(Color.white)
                .padding(.leading, 45)
                .padding(.top, 75)
                
                QualiMatchCard(
                    percentage: "\(jobsController.averageMatch)%",
                    title: "Average Qualification Match",
                    subtext: "\(jobsController.matchedListings.count) matched \u{00B7} auto-applied"
                )
                .padding(.leading, 19)
                .padding(.top, 25)
                
                topMatch
                    .padding(.leading, 19)
                    .padding(.top, 29)
                
                applicationStatus
                    .padding(.leading, 32)
                    .padding(.top, 25)
                
                Text("Recent Activity")
                    .scaledFont(size: 18, weight: .medium)
                    .foregroundStyle(Color.siriusText)
                    .padding(.leading, 32)
                    .padding(.top, 16)
                
                VStack(spacing: 17) {
                    if controller.allApplications.isEmpty {
                        Text("No applications yet. You are applied automatically when a job matches you at 60% or more.")
                            .scaledFont(size: 11)
                            .foregroundStyle(.black.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                            .fluidFrame(width: 333)
                    } else {
                        ForEach(controller.allApplications.prefix(5)) { app in
                            JobApplicationCard(application: app)
                        }
                    }
                }
                .padding(.leading, 34)
                .padding(.top, 13)
                .padding(.bottom, 120)          // room for the bottom bar
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .ignoresSafeArea(.container, edges: .top)
        .appBg()
        .navigationBarBackButtonHidden(true)
    }
    
    // "Top Match For You · Auto-applied" panel (#03527b, radius 10, 15pt padding)
    private var topMatch: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Top Match For You \u{00B7} Auto-applied")
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
                        width: 333
                    )
                }
                .buttonStyle(.plain)
            } else {
                Text("No matching jobs yet. Jobs at 60% or more appear here.")
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
