//
//  LogInView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct LogInPage: View {
    
    @State private var logInEmail: String = ""
    @State private var logInPassword: String = ""
    @State private var signUpScreen = false
    @State private var loggedInAccount: UserAccount?
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
                    .frame(maxWidth: .infinity, minHeight: geo.size.height)     // lets the panel stretch to the bottom
                }
            }
            .ignoresSafeArea(.container)
            .scrollDismissesKeyboard(.interactively)
            .appBg()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $signUpScreen) {
                RoleSelectionPage()
            }
            .navigationDestination(item: $loggedInAccount) { account in
                MainTabView(account: account)
            }
            .task {
                // Reopen the saved session (once per app launch)
                if let account = await auth.restoreSession() {
                    loggedInAccount = account
                }
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
            case .success(let account):
                logInPassword = ""
                loggedInAccount = account
            }
            isWorking = false
        }
    }
}

// .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 4)

#Preview {
    LogInPage()
}
