//
//  AplJobDiscoveryPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct AplJobDiscoveryPage: View {
    
    @State private var jobDetailsScreen = false
    
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
                    
                    Text("Search")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                }
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .frame(width: 350, height: 42)
                
                ScrollView{
                    VStack{
                        Button{
                            jobDetailsScreen = true
                        } label: {
                            AplJobCard(
                                jobTitle: "Junior Software Developer",
                                companyName: "OpeniT Philippines, Inc.",
                                jobLocation: "Lucena City",
                                jobSalary: "₱40,000 - ₱50,000",
                                matchPrct: 95
                            )
                            .padding(.bottom, 8)
                        }
                        
                        AplJobCard(
                            jobTitle: "UI/UX Designer",
                            companyName: "DEF Company",
                            jobLocation: "Tagaytay City",
                            jobSalary: "₱30,000 - ₱40,000",
                            matchPrct: 50
                        )
                        .padding(.bottom, 8)
                        
                        AplJobCard(
                            jobTitle: "UI/UX Designer",
                            companyName: "XYZ Company",
                            jobLocation: "Calamba City",
                            jobSalary: "₱20,000 - ₱27,000",
                            matchPrct: 80
                        )
                        .padding(.bottom, 8)
                        
                        AplJobCard(
                            jobTitle: "UI/UX Designer",
                            companyName: "Shangrila The Fort",
                            jobLocation: "Lucena City",
                            jobSalary: "₱20,000 - ₱27,000",
                            matchPrct: 80
                        )
                        .padding(.bottom, 8)
                        
                        AplJobCard(
                            jobTitle: "UI/UX Designer",
                            companyName: "XYZ Company",
                            jobLocation: "Calamba City",
                            jobSalary: "₱20,000 - ₱27,000",
                            matchPrct: 25
                        )
                        .padding(.bottom, 8)
                        
                        AplJobCard(
                            jobTitle: "UI/UX Designer",
                            companyName: "XYZ Company",
                            jobLocation: "Calamba City",
                            jobSalary: "₱20,000 - ₱27,000",
                            matchPrct: 40
                        )
                        .padding(.bottom, 8)
                        
                        AplJobCard(
                            jobTitle: "UI/UX Designer",
                            companyName: "DEF Company",
                            jobLocation: "Tagaytay City",
                            jobSalary: "₱30,000 - ₱40,000",
                            matchPrct: 69
                        )
                        .padding(.bottom, 8)
                    }
                    .padding(.top, 20)
                }
            }
            .padding(.top, 15)
            .padding(.horizontal, 30)
            .appBg()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $jobDetailsScreen) {
                JobDetailsView()
            }
        }
    }
}

#Preview{
    AplJobDiscoveryPage()
}
