//
//  RoleSelectionView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct RoleSelectionPage: View {
    
    @State private var selectedRole: UserRole?
    @State private var nextScreen = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 0) {
                        AuthBrandHeader()
                        
                        AuthPanel(heading: "Choose your role", subheading: "Tell us how you\u{2019}ll use SIRIUS", fillsScreenBottom: true) {
                            RoleCard(
                                title: "APPLICANT",
                                description: "Find opportunities that match your qualifications",
                                icon: "person",
                                isSelected: selectedRole == .applicant) { selectedRole = .applicant }
                            
                            RoleCard(
                                title: "EMPLOYER",
                                description: "Find qualified candidates faster.",
                                icon: "briefcase",
                                isSelected: selectedRole == .employer) { selectedRole = .employer }
                            
                            AuthButton(title: "Continue", fontSize: 16, isEnabled: selectedRole != nil) {
                                nextScreen = true
                            }
                            
                            Spacer(minLength: 24)
                            
                            AuthFooterLink(
                                prompt: "Have an account already?",
                                link: "Log In",
                                promptColor: .siriusMuted,
                                linkColor: .siriusAction
                            ) {
                                dismiss()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: geo.size.height)
                }
            }
            .ignoresSafeArea(.container)
            .scrollDismissesKeyboard(.interactively)
            .appBg()
            .navigationDestination(isPresented: $nextScreen) {
                if selectedRole == .applicant {
                    AplSignUpPage()
                } else if selectedRole == .employer {
                    EmpSignUpPage()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    RoleSelectionPage()
}
