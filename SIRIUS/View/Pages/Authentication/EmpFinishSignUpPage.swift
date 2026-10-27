//
//  EmpFinishSignUpPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/13/26.
//

import SwiftUI

// Employer sign up — step 3 of 3: account credentials
// (Figma: Finish Sign Up Screen (Employer))
struct EmpFinishSignUpPage: View {
    
    @ObservedObject var infoController: EmpInfoController
    
    @Environment(\.dismiss) private var dismiss
    @State private var confirmPassword = ""
    @State private var homeScreen = false
    @State private var isWorking = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AuthBrandHeader()
                
                AuthPanel(heading: "Create your account", subheading: "Choose a password for \(infoController.employer.email)") {
                    AuthField(
                        title: "Password",
                        placeholder: "Enter your password",
                        text: $infoController.employer.password,
                        isSecure: true
                    )
                    
                    AuthField(
                        title: "Confirm Password",
                        placeholder: "Re-enter your password",
                        text: $confirmPassword,
                        isSecure: true
                    )
                    
                    FormErrorText(message: infoController.signUpError)
                    
                    AuthButton(title: isWorking ? "Creating account\u{2026}" : "Complete Profile", isEnabled: !isWorking) {
                        isWorking = true
                        Task {
                            if await infoController.completeSignUp(confirmPassword: confirmPassword) {
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
                    infoController.clearError()
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
            MainTabView(role: .employer, infoController: infoController)
        }
    }
}

#Preview {
    NavigationStack {
        EmpFinishSignUpPage(infoController: EmpInfoController())
    }
}
