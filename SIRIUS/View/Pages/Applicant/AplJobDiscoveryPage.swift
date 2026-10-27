//
//  AplJobDiscoveryPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

// Lists every active job with the applicant's match percentage (best match first).
// Applying is automatic: jobs at 60% or more already appear under My Applications.
struct AplJobDiscoveryPage: View {
    
    @EnvironmentObject private var jobsController: AplJobsController
    @State private var selectedJobID: String?           // pushes that job's details
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 0){
                Text("Discover Jobs")
                    .scaledFont(size: 32, weight: .medium)
                    .foregroundStyle(Color.white)
                    .padding(.top, 75)
                
                HStack(spacing: 10){
                    Image(systemName: "magnifyingglass")
                        .scaledFont(size: 15)
                        .foregroundStyle(Color.white)
                    
                    TextField(
                        "",
                        text: $jobsController.searchText,
                        prompt: Text("Search").foregroundColor(.white)
                    )
                    .scaledFont(size: 18)
                    .foregroundStyle(Color.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    
                    if !jobsController.searchText.isEmpty {
                        Button {
                            jobsController.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.white.opacity(0.8))
                        }
                        .accessibilityLabel("Clear search")
                    }
                }
                .padding(.horizontal, 20)
                .fluidFrame(width: 343, height: 42)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.top, 17)
                
                if jobsController.listings.isEmpty {
                    emptyState
                } else {
                    ScrollView{
                        VStack(spacing: 17){
                            ForEach(jobsController.listings) { listing in
                                Button {
                                    selectedJobID = listing.id
                                } label: {
                                    AplJobCard(
                                        jobTitle: listing.job.jobPos,
                                        companyName: listing.job.companyName.isEmpty ? "Company" : listing.job.companyName,
                                        jobLocation: listing.job.requiredLoc.isEmpty ? listing.job.workSetup.rawValue : listing.job.requiredLoc,
                                        jobSalary: listing.job.salary > 0 ? "\(listing.job.salaryText) / month" : "",
                                        matchPrct: Double(listing.percentage),
                                        isAutoApplied: listing.hasApplied
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 36)
                        .padding(.bottom, 120)          // room for the bottom bar
                    }
                    .scrollIndicators(.hidden)
                    .padding(.leading, 4)
                }
            }
            .padding(.leading, 30)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .ignoresSafeArea(.container, edges: .top)
            .appBg()
            .boardLoadState()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(item: $selectedJobID) { jobID in
                if let listing = jobsController.allListings.first(where: { $0.id == jobID }) {
                    JobDetailsView(listing: listing)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "briefcase")
                .scaledFont(size: 32)
            Text(jobsController.searchText.isEmpty ? "No jobs posted yet" : "No jobs match your search")
                .scaledFont(size: 15, weight: .medium)
        }
        .foregroundStyle(Color.siriusInk)
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

#Preview{
    AplJobDiscoveryPage()
        .environmentObject(AplJobsController(
            info: AplInfoController(applicant: AplInfoController.blankApplicant()),
            board: JobBoard()
        ))
}
