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
    @State private var isWorking = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AuthBrandHeader()
                
                AuthPanel(heading: "Create your account", subheading: "Enter your email and choose a password") {
                    VStack(spacing: 10) {
                        AppTextField(
                            title: "Email Address",
                            placeholder: "e.g., 123@gmail.com",
                            text: $applicantController.applicant.email,
                            keyboardType: .emailAddress,
                            widthField: 325
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        
                        AppTextField(
                            title: "Password",
                            placeholder: "Enter your password",
                            text: $applicantController.applicant.password,
                            isSecure: true,
                            widthField: 325
                        )
                        
                        AppTextField(
                            title: "Confirm Password",
                            placeholder: "Re-enter your password",
                            text: $confirmPassword,
                            isSecure: true,
                            widthField: 325
                        )
                    }
                    .frame(maxWidth: .infinity)
                    
                    FormErrorText(message: applicantController.signUpError)
                    
                    AuthButton(title: isWorking ? "Creating account\u{2026}" : "Complete Profile", isEnabled: !isWorking) {
                        isWorking = true
                        Task {
                            if await applicantController.completeSignUp(confirmPassword: confirmPassword) {
                                homeScreen = true
                            }
                            isWorking = false
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topLeading) {
                CircleBackButton {
                    applicantController.clearError()
                    dismiss()
                }
                .padding(.leading, 29)
                .padding(.top, 62)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
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
