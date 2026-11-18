//
//  LogInPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct LogInPage: View {

    @State private var logInEmail: String = ""
    @State private var logInPassword: String = ""
    @State private var signUpScreen = false
    @State private var errorMessage: String?
    @State private var isWorking = false

    @ObservedObject private var auth = AuthController.shared

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 0) {
                        AuthBrandHeader()

                        AuthPanel(heading: "Welcome back", subheading: "Log in to continue to SIRIUS", fillsScreenBottom: true) {
                            AuthField(
                                title: "Email",
                                placeholder: "Enter your email",
                                text: $logInEmail,
                                keyboardType: .emailAddress
                            )

                            AuthField(
                                title: "Password",
                                placeholder: "Enter your password",
                                text: $logInPassword,
                                isSecure: true
                            )

                            FormErrorText(message: errorMessage)

                            AuthButton(title: isWorking ? "Logging in\u{2026}" : "Continue", isEnabled: !isWorking) {
                                logIn()
                            }

                            Spacer(minLength: 24)

                            AuthFooterLink(
                                prompt: "Don\u{2019}t have an account yet?",
                                link: "Sign Up",
                                promptColor: .siriusMuted,
                                linkColor: .siriusAction
                            ) {
                                signUpScreen = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: geo.size.height)
                }
            }
            .ignoresSafeArea(.container)
            .scrollDismissesKeyboard(.interactively)
            .appBg()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $signUpScreen) {
                RoleSelectionPage()
            }
        }
    }

    private func logIn() {
        isWorking = true
        errorMessage = nil
        Task {
            switch await auth.login(email: logInEmail, password: logInPassword) {
            case .failure(let error):
                errorMessage = error.errorDescription
            case .success:
                logInPassword = ""
            }
            isWorking = false
        }
    }
}

#Preview {
    LogInPage()
}
