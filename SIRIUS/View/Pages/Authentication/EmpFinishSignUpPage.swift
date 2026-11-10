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
    @State private var otpCode = ""
    @State private var codeSent = false
    @State private var homeScreen = false
    @State private var isWorking = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AuthBrandHeader()
                
                AuthPanel(heading: "Create your account", subheading: "Enter your email and choose a password") {
                    Group {
                        AuthField(
                            title: "Email Address",
                            placeholder: "e.g., 123@gmail.com",
                            text: $infoController.employer.email,
                            keyboardType: .emailAddress
                        )
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
                    }
                    .disabled(codeSent)

                    // NEW: OTP field, directly below Confirm Password
                    if codeSent {
                        AuthField(
                            title: "Verification Code",
                            placeholder: "Enter the code sent to your email",
                            text: $otpCode,
                            keyboardType: .numberPad
                        )
                        .textContentType(.oneTimeCode)
                        .onChange(of: otpCode) { _, newValue in
                            otpCode = String(newValue.filter(\.isNumber).prefix(6))
                        }

                        HStack {
                            Button("Resend code") {
                                Task {
                                    if await infoController.resendVerificationCode() { otpCode = "" }
                                }
                            }
                            Spacer()
                            Button("Change email") {
                                codeSent = false
                                otpCode = ""
                                infoController.clearError()
                            }
                        }
                        .font(.footnote)
                        .padding(.horizontal, 11)
                    }

                    FormErrorText(message: infoController.signUpError)

                    AuthButton(
                        title: isWorking
                            ? (codeSent ? "Creating account\u{2026}" : "Sending code\u{2026}")
                            : (codeSent ? "Complete Profile" : "Send Verification Code"),
                        isEnabled: !isWorking
                    ) {
                        isWorking = true
                        Task {
                            if codeSent {
                                if await infoController.completeSignUp(confirmPassword: confirmPassword, code: otpCode) {
                                    homeScreen = true
                                }
                            } else {
                                codeSent = await infoController.sendVerificationCode(confirmPassword: confirmPassword)
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
