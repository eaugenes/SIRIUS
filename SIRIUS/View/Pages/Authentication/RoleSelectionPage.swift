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
        NavigationStack{
            ScrollView {
                VStack(spacing: 0) {
                    AuthBrandHeader()
                    
                    AuthPanel(heading: "Choose your role", subheading: "Tell us how you\u{2019}ll use SIRIUS") {
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
                    }
                    
                    AuthFooterLink(prompt: "Have an account already?", link: "Log In") {
                        dismiss()
                    }
                    .padding(.top, 43)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(.container, edges: .top)
            .appBg()
            .navigationDestination(isPresented: $nextScreen) {
                if selectedRole == .applicant {
                    AplSignUpPage()
                }  else if selectedRole == .employer {
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
