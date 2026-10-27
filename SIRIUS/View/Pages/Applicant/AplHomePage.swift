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
    
    private var firstName: String {
        let name = applicantController.applicant.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "there" : name
    }
    
    var body: some View {
        ScrollView {
            HStack{
                VStack(alignment: .leading) {
                    Text("Greetings,")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                    
                    Text("\(firstName)!")
                        .font(.system(size: 25))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .padding(.leading, 30)
                
                Spacer()
            }
            .padding(.top, 5)
            
            QualiMatchCard(
                percentage: "\(jobsController.averageMatch)%",
                title: "Average Qualification Match",
                subtext: "\(jobsController.matchedListings.count) matched positions in total"
            )
            .padding(15)
            
            VStack(alignment: .leading){
                Text("Top Match For You")
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                
                if let top = jobsController.topListing {
                    Button {
                        selectedTab = .jobs
                    } label: {
                        AplJobCard(
                            jobTitle: top.job.jobPos,
                            companyName: top.job.companyName.isEmpty ? "Company" : top.job.companyName,
                            jobLocation: top.job.requiredLoc.isEmpty ? top.job.workSetup.rawValue : top.job.requiredLoc,
                            matchPrct: Double(top.percentage)
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("No matching jobs yet. Jobs at 60% or more appear here.")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(maxWidth: .infinity, minHeight: 88)
                }
            }
            .padding(.horizontal, 10)
            .frame(width: 363, height: 141)
            .background(
                Color(
                    red: 3/255,
                    green: 82/255,
                    blue: 123/255
                )
            )
            .cornerRadius(10)
            
            HStack{
                VStack(alignment: .leading){
                    Text("Application")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                    
                    Text("Status")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                }
                
                Spacer()
                
                ZStack{
                    HStack{
                        VStack{
                            Text("\(controller.allApplications.count)")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                            
                            Text("Applied")
                                .font(.system(size: 8))
                                .fontWeight(.regular)
                                .foregroundStyle(.black)
                        }
                        .frame(width: 66, height: 31)
                        
                        Divider()
                            .frame(width: 1)
                            .background(Color.gray)
                        
                        VStack{
                            Text("\(controller.count(of: .interview))")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                            
                            Text("Interview")
                                .font(.system(size: 8))
                                .fontWeight(.regular)
                                .foregroundStyle(.black)
                        }
                        .frame(width: 66, height: 31)
                        
                        Divider()
                            .frame(width: 1)
                            .background(Color.gray)
                        
                         VStack{
                            Text("\(controller.count(of: .accepted))")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                            
                            Text("Accepted")
                                .font(.system(size: 8))
                                .fontWeight(.regular)
                                .foregroundStyle(.black)
                        }
                         .frame(width: 66, height: 31)
                    }
                }
                .padding(
                    EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
                .background(Color.white)
                .cornerRadius(10)
                .frame(maxWidth: 244, maxHeight: 53)
                .shadow(
                    color: Color.gray,
                    radius: 4
                )
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            
            HStack{
                Text("Recent Activity")
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                    .padding(.leading, 30)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                if controller.allApplications.isEmpty {
                    Text("No applications yet. You are applied automatically when a job matches you at 60% or more.")
                        .font(.system(size: 11))
                        .foregroundStyle(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                } else {
                    ForEach(controller.allApplications.prefix(5)) { app in
                        JobApplicationCard(application: app)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)          // room for the bottom bar
        }
        .appBg()
        .navigationBarBackButtonHidden(true)
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
