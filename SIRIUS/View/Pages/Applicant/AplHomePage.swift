//
//  AplHomePage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct AplHomePage: View {
    
    @StateObject private var controller = AplApplicationsController()
    
    var body: some View {
        ScrollView {
            HStack{
                VStack(alignment: .leading) {
                    Text("Greetings,")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                    
                    Text("Nea Presto!")
                        .font(.system(size: 25))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .padding(.leading, 30)
                
                Spacer()
            }
            .padding(.top, 5)
            
            QualiMatchCard(
                percentage: "90%",
                title: "Average Qualification Match",
                subtext: "12 matched positions in total"
            )
            .padding(15)
            
            VStack(alignment: .leading){
                Text("Top Match For You")
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                
                AplJobCard(
                    jobTitle: "Junior Software Developer",
                    companyName: "OpeniT Philippines, Inc.",
                    jobLocation: "Lucena City",
                    jobSalary: "₱40,000 - ₱50,000",
                    matchPrct: 95
                )
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
                            Text("10")
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
                            Text("2")
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
                            Text("0")
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
            
            //      Dummy Data
            VStack{
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(controller.filteredApplications) { app in
                            JobApplicationCard(application: app)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .appBg()
        .navigationBarBackButtonHidden(true)
    }
}

#Preview{
    AplHomePage()
}
