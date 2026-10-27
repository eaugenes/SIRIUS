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
    @State private var loggedInAccount: UserAccount?        // set after a successful log in
    @State private var errorMessage: String?
    @State private var isWorking = false
    
    @ObservedObject private var auth = AuthController.shared
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 0) {
                    AuthBrandHeader()
                    
                    AuthPanel(heading: "Welcome back", subheading: "Log in to continue to SIRIUS") {
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
                        
                        HStack(spacing: 10) {
                            Rectangle().fill(Color.siriusFieldBorder).frame(height: 1)
                            Text("or continue with")
                                .scaledFont(size: 13)
                                .foregroundStyle(Color.siriusMuted)
                                .fixedSize()
                            Rectangle().fill(Color.siriusFieldBorder).frame(height: 1)
                        }
                        
                        // TODO(Supabase): wire to Supabase Auth Google OAuth (signInWithOAuth(provider: .google))
                        Button {
                            errorMessage = "Google sign in will be available once Supabase is connected."
                        } label: {
                            HStack(spacing: 10) {
                                GoogleLogo(size: 22)
                                Text("Google")
                                    .scaledFont(size: 16, weight: .medium)
                                    .foregroundStyle(Color.siriusInk)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 52)
                            .background(Color.siriusSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.siriusFieldBorder, lineWidth: 1.5))
                        }
                    }
                    
                    AuthFooterLink(prompt: "Don\u{2019}t have an account yet?", link: "Sign Up") {
                        signUpScreen = true
                    }
                    .padding(.top, 43)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(.container, edges: .top)
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
