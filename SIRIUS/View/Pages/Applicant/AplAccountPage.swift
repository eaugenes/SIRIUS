//
//  AplAccountPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct AplAccountPage: View {
    
    @EnvironmentObject private var applicantController: AplInfoController
    
    @State private var logInScreen = false
    @State private var editAccountScreen = false
    
    private var applicant: Applicant { applicantController.applicant }
    
    private var experienceText: String {
        let years = applicant.yrExp
        if years == 1 { return "1 year" }
        return years == years.rounded() ? "\(Int(years)) years" : String(format: "%.1f years", years)
    }
    
    private func value(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "—" : trimmed
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                Group {
                    if let picture = applicant.profilePicture {
                        Image(uiImage: picture)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                    }
                }
                
                Text(value(applicant.fullName))
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                Text("@\(applicant.username)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            
            VStack{
                VStack{
                    row("Date of Birth", value(applicant.birthDate))
                    Divider()
                    row("Location", value(applicant.location))
                    Divider()
                    row("Contact Number", value(applicant.contactNumber))
                    Divider()
                    row("Email", value(applicant.email))
                    Divider()
                    row("Educational Attainment", value(applicant.program))
                    Divider()
                    row("Work Experience", experienceText)
                    Divider()
                    HStack(alignment: .top){
                        Text("Core Languages")
                        Spacer()
                        VStack(alignment: .trailing){
                            ForEach(applicant.coreLang, id: \.self) { language in
                                Text(language)
                            }
                            if applicant.coreLang.isEmpty { Text("—") }
                        }
                    }
                    
                    Button{
                        editAccountScreen = true
                    } label: {
                        HStack{
                            Spacer()
                            Image(systemName: "pencil.line")
                                .font(.system(size: 20))
                                .padding(5)
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.white)
                                .background(
                                    Color(
                                        red: 0/255,
                                        green: 61/255,
                                        blue: 92/255
                                    )
                                )
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
                        }
                    }
                    .accessibilityLabel("Edit profile")
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
                .frame(minWidth: 365, minHeight: 400)
                .foregroundStyle(.black)
                .background(.white)
                .cornerRadius(10)
                .shadow(
                    radius: 5,
                    x: 0,
                    y: 5
                )
                
                Button{
                    applicantController.signOut()
                    logInScreen = true
                } label: {
                    Text("Sign Out")
                        .fontWeight(.regular)
                        .padding(.horizontal, 20)
                        .frame(width: 280, height: 38)
                        .foregroundStyle(.black)
                        .background(.white)
                        .cornerRadius(10)
                        .padding(.top, 30)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                }
            }
            .frame(width: 350, height:.infinity)
            .appBg()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $logInScreen) {
                LogInPage()
            }
            .navigationDestination(isPresented: $editAccountScreen) {
                AplEditProfilePage()
            }
        }
    }
    
    private func row(_ title: String, _ text: String) -> some View {
        HStack{
            Text(title)
            Spacer()
            Text(text)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    AplAccountPage()
        .environmentObject(AplInfoController(applicant: AplInfoController.blankApplicant()))
}
