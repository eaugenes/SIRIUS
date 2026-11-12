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
        NavigationStack {
            VStack(spacing: 0) {
                header
                ScrollView {     // NOTE: The header stays on top and Sign Out stays above the bottom bar
                    infoCard
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                
                Button {
                    applicantController.signOut()
                    logInScreen = true
                } label: {
                    Text("Sign Out")
                        .scaledFont(size: 12)
                        .foregroundStyle(Color.siriusText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(Color.siriusSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .frame(maxWidth: 333)
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, NavBarMetrics.clearance)         // sits just above the bottom bar
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .appBg()
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $logInScreen) {
                LogInPage()
            }
            .navigationDestination(isPresented: $editAccountScreen) {
                // Pass the objects in: tab pages live in a TabView, so SwiftUI hosts this page outside the
                // tab's environment and it would not find them otherwise (crash: "No ObservableObject ... found")
                AplEditProfilePage()
                    .environmentObject(applicantController)
            }
        }
    }
    
    // White header: avatar, name, username and the edit button
    private var header: some View {
        HStack(spacing: 14) {
            avatar
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value(applicant.fullName))
                    .scaledFont(size: 18)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("@\(applicant.username)")
                    .scaledFont(size: 12)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color.siriusText)
            .frame(maxWidth: .infinity)
            
            Button {
                applicantController.clearError()
                editAccountScreen = true
            } label: {
                Image(systemName: "pencil.line")
                    .scaledFont(size: 17)
                    .foregroundStyle(Color.white)
                    .frame(width: 44, height: 44)
                    .background(Color.siriusPanel)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: Color.black.opacity(0.25), radius: 4, x: 2, y: 3)
            }
            .accessibilityLabel("Edit profile")
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity)
        .background(Color.siriusSurface.ignoresSafeArea(edges: .top))
    }
    
    private var avatar: some View {
        Group {
            if let picture = applicant.profilePicture {
                Image(uiImage: picture)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(applicant.firstName.defaultAvatar.isEmpty ? "?" : applicant.firstName.defaultAvatar)
                    .scaledFont(size: 28, weight: .semibold)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.siriusPanel)
            }
        }
        .frame(width: 66, height: 66)
        .clipShape(Circle())
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 4, y: 4)
    }
    
    // White card: personal details, then the applicant's projects at the bottom
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
            row("Work Setup", value(applicant.workSetUp))
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
            .padding(.vertical, 14)
            line
            
            // Projects: title, description, pictures
            VStack(alignment: .leading, spacing: 10) {
                label("Projects")
                ProjectsSection(projects: applicant.projects)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 14)
        }
        .foregroundStyle(Color.siriusText)
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 20)
        .frame(maxWidth: 370, alignment: .top)
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
        HStack(spacing: 12) {
            label(title)
            Spacer(minLength: 8)
            Text(text)
                .scaledFont(size: 12, weight: .medium)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.trailing)
        }
        .frame(minHeight: 46)
    }
}

#Preview {
    AplAccountPage()
        .environmentObject(AplInfoController(applicant: AplInfoController.blankApplicant()))
}
