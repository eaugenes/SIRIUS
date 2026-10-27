//
//  AplFinishSignUpPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct AplFinishSignUpPage: View {
    
    @ObservedObject var applicantController: AplInfoController
    
    @Environment(\.dismiss) private var dismiss
    @State private var confirmPassword = ""
    @State private var homeScreen = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        applicantController.clearError()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 26))
                            .foregroundStyle(Color.black)
                            .frame(width: 44, height: 44, alignment: .leading)
                    }
                    .accessibilityLabel("Back")
                    
                    Spacer()
                }
                .padding(.leading, 39)
                .padding(.top, 12)
                
                Image("sirius-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 158, height: 148)
                
                Text("SIRIUS")
                    .font(.system(size: 64))
                    .fontWeight(.medium)
                    .tracking(12.8)
                    .padding(.leading, 12.8)            // balances the trailing tracking space
                    .padding(.top, 10)
                
                Text("In a sky full of opportunities, let the right one find you.")
                    .font(.system(size: 11))
                    .fontWeight(.light)
                    .foregroundStyle(Color.siriusTextSecondary)
                    .padding(.bottom, 60)
                
                VStack(spacing: 10) {
                    AppTextField(
                        title: "Username",
                        placeholder: "Enter your username",
                        text: $applicantController.applicant.username
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    
                    AppTextField(
                        title: "Password",
                        placeholder: "Enter your password",
                        text: $applicantController.applicant.password,
                        isSecure: true
                    )
                    
                    AppTextField(
                        title: "Confirm Password",
                        placeholder: "Re-enter your password",
                        text: $confirmPassword,
                        isSecure: true
                    )
                }
                
                FormErrorText(message: applicantController.signUpError)
                    .padding(.top, 16)
                
                SiriusButton(title: "Complete Profile") {
                    if applicantController.completeSignUp(confirmPassword: confirmPassword) {
                        homeScreen = true
                    }
                }
                .padding(.top, applicantController.signUpError == nil ? 44 : 16)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .appBg()
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $homeScreen) {
            MainTabView(role: .applicant, applicantController: applicantController)
        }
    }
}

#Preview {
    NavigationStack {
        AplFinishSignUpPage(applicantController: AplInfoController(applicant: AplInfoController.blankApplicant()))
    }
}
