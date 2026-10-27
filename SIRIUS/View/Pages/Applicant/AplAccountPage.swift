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
            ZStack(alignment: .top) {
                // White header (avatar, name, username, edit)
                VStack {
                    Rectangle().fill(Color.siriusSurface).frame(height: 180)
                    Spacer()
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        Color.clear.frame(width: 402, height: 180)
                        
                        avatar
                            .offset(x: 33, y: 88)
                        
                        VStack(spacing: 2) {
                            Text(value(applicant.fullName))
                                .scaledFont(size: 18)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            Text("@\(applicant.username)")
                                .scaledFont(size: 12)
                        }
                        .foregroundStyle(Color.siriusText)
                        .frame(width: 199)
                        .offset(x: 116, y: 96)
                        
                        Button{
                            editAccountScreen = true
                        } label: {
                            Image(systemName: "pencil.line")
                                .scaledFont(size: 17)
                                .foregroundStyle(Color.white)
                                .padding(10)
                                .background(Color.siriusPanel)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 2, y: 3)
                        }
                        .accessibilityLabel("Edit profile")
                        .offset(x: 329, y: 101)
                    }
                    .frame(width: 402, height: 180)
                    
                    infoCard
                        .padding(.top, 27)
                    
                    Button{
                        applicantController.signOut()
                        logInScreen = true
                    } label: {
                        Text("Sign Out")
                            .scaledFont(size: 12)
                            .foregroundStyle(Color.siriusText)
                            .fluidFrame(width: 333, height: 34)
                            .background(Color.siriusSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.top, 26)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea(.container, edges: .top)
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
    
    private var avatar: some View {
        Group {
            if let picture = applicant.profilePicture {
                Image(uiImage: picture)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .scaledFont(size: 28)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.siriusPanel)
            }
        }
        .frame(width: 66, height: 66)
        .clipShape(Circle())
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 4, y: 4)
    }
    
    // 370 x 512 white card: Date of Birth, Location, Contact, Program, Experience, Languages
    private var infoCard: some View {
        VStack(spacing: 0) {
            row("Date of Birth", value(applicant.birthDate))
            line
            row("Location", value(applicant.location))
            line
            row("Contact Number", value(applicant.contactNumber))
            line
            row("Email", value(applicant.email))
            line
            row("Program", value(applicant.program))
            line
            row("Work Experience", experienceText)
            line
            row("Resume", applicant.resumeFileName.isEmpty ? "\u{2014}" : applicant.resumeFileName)
            line
            HStack(alignment: .top) {
                label("Core Languages")
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    ForEach(applicant.coreLang, id: \.self) { language in
                        Text(language).scaledFont(size: 12, weight: .medium)
                    }
                    if applicant.coreLang.isEmpty { Text("\u{2014}").scaledFont(size: 12, weight: .medium) }
                }
            }
            .padding(.top, 14)
            
            Spacer(minLength: 0)
        }
        .foregroundStyle(Color.siriusText)
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 20)
        .frame(maxWidth: 370, minHeight: 512, alignment: .top)
        .background(Color.siriusSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 4)
    }
    
    private var line: some View {
        Rectangle().fill(Color.black.opacity(0.35)).frame(height: 0.5)
    }
    
    private func label(_ text: String) -> some View {
        Text(text).scaledFont(size: 12, weight: .heavy)
    }
    
    private func row(_ title: String, _ text: String) -> some View {
        HStack{
            label(title)
            Spacer()
            Text(text)
                .scaledFont(size: 12, weight: .medium)
                .multilineTextAlignment(.trailing)
        }
        .frame(height: 46)
    }
}

#Preview {
    AplAccountPage()
        .environmentObject(AplInfoController(applicant: AplInfoController.blankApplicant()))
}
