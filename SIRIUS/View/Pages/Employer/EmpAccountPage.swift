//
//  EmpAccountPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/13/26.
//

import SwiftUI
import UIKit           // UIKeyboardType / UIImage

// Employer "Profile" tab (Figma: Account (Employer))
struct EmpAccountPage: View {
    
    @EnvironmentObject private var infoController: EmpInfoController
    
    @State private var editScreen = false
    @State private var logInScreen = false
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(spacing: 25) {
                    aboutCard
                    companyInfoCard
                }
                .padding(.top, 32)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            
            SiriusButton(title: "Sign Out", isFilled: false, width: 333, height: 34, fontSize: 12) {
                infoController.signOut()
                logInScreen = true
            }
            .padding(.bottom, 95)           // sits just above the bottom bar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBg()
        .navigationDestination(isPresented: $editScreen) {
            EmpCompanyInfoPage(infoController: infoController, mode: .edit)
        }
        .navigationDestination(isPresented: $logInScreen) {
            LogInPage()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    // Dark-blue band with the company initial, name, email and edit button
    private var header: some View {
        HStack(spacing: 16) {
            Group {
                if let picture = infoController.employer.profilePicture {
                    Image(uiImage: picture)
                        .resizable()
                        .scaledToFill()
                } else {
                    Text(infoController.companyInitial)
                        .scaledFont(size: 25)
                        .foregroundStyle(Color.siriusText)
                }
            }
            .frame(width: 50, height: 50)
            .background(Color.siriusSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(infoController.displayCompanyName)
                    .scaledFont(size: 18)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(infoController.displayValue(infoController.displayEmail))
                    .scaledFont(size: 12)
                    .lineLimit(1)
            }
            .foregroundStyle(Color.white)
            
            Spacer()
            
            Button {
                infoController.clearError()
                editScreen = true
            } label: {
                Image(systemName: "pencil.line")
                    .scaledFont(size: 20)
                    .foregroundStyle(Color.siriusInk)
                    .frame(width: 44, height: 44)
                    .background(Color.siriusSurface)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 4)
            }
            .accessibilityLabel("Edit company information")
        }
        .padding(.horizontal, 32)
        .padding(.top, 30)
        .padding(.bottom, 34)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20)
                .fill(Color.siriusNavy.opacity(0.75))
                .ignoresSafeArea(edges: .top)
        )
    }
    
    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About Company")
                .scaledFont(size: 16, weight: .medium)
                .foregroundStyle(Color.siriusText)
            
            Text(infoController.displayValue(infoController.company.cmpDesc))
                .scaledFont(size: 13, weight: .light)
                .foregroundStyle(Color.siriusText)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 6)
        }
        .padding(.horizontal, 19)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .fluidFrame(width: 352, alignment: .leading)
        .frame(minHeight: 221, alignment: .topLeading)
        .background(Color.siriusSurface)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 4)
    }
    
    private var companyInfoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Company Information")
                .scaledFont(size: 14, weight: .medium)
                .foregroundStyle(Color.siriusText)
                .padding(.bottom, 10)
            
            infoRow(label: "Founded", value: infoController.company.founded)
            Divider().overlay(Color.siriusBorder)
            infoRow(label: "Location", value: infoController.company.loc)
            Divider().overlay(Color.siriusBorder)
            infoRow(label: "Website", value: infoController.company.website)
        }
        .padding(.horizontal, 19)
        .padding(.vertical, 16)
        .fluidFrame(width: 352, alignment: .leading)
        .background(Color.siriusSurface)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 4)
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .scaledFont(size: 12)
            
            Spacer()
            
            Text(infoController.displayValue(value))
                .scaledFont(size: 12, weight: .medium)
                .lineLimit(1)
        }
        .foregroundStyle(Color.siriusText)
        .padding(.horizontal, 4)
        .frame(height: 45)
    }
}

#Preview {
    NavigationStack {
        EmpAccountPage()
            .environmentObject(EmpInfoController.sample())
    }
}
