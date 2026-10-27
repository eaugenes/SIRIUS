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
            VStack(alignment: .leading){
                Text("Discover Jobs")
                    .font(.system(size: 32))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.white)
                
                HStack{
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.white)
                    
                    TextField(
                        "",
                        text: $jobsController.searchText,
                        prompt: Text("Search").foregroundColor(.white.opacity(0.8))
                    )
                    .font(.system(size: 20))
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
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .frame(width: 350, height: 42)
                
                if jobsController.listings.isEmpty {
                    emptyState
                } else {
                    ScrollView{
                        VStack{
                            ForEach(jobsController.listings) { listing in
                                Button {
                                    selectedJobID = listing.id
                                } label: {
                                    AplJobCard(
                                        jobTitle: listing.job.jobPos,
                                        companyName: listing.job.companyName.isEmpty ? "Company" : listing.job.companyName,
                                        jobLocation: listing.job.requiredLoc.isEmpty ? listing.job.workSetup.rawValue : listing.job.requiredLoc,
                                        matchPrct: Double(listing.percentage)
                                    )
                                    .padding(.bottom, 8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 100)          // room for the bottom bar
                    }
                }
            }
            .padding(.top, 15)
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .appBg()
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
                .font(.system(size: 32))
            Text(jobsController.searchText.isEmpty ? "No jobs posted yet" : "No jobs match your search")
                .font(.system(size: 15, weight: .medium))
        }
        .foregroundStyle(Color.siriusNavy)
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
