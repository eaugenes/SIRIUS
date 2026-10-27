//
//  EmpSignUpView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/10/26.
//

import SwiftUI

// Employer sign up — step 1 of 3: Personal Information
// (Figma: Sign Up Screen (Employer))
struct EmpSignUpPage: View {
    
    // Owns the employer controller for the whole sign up flow and the employer app after it
    @StateObject private var infoController = EmpInfoController()
    
    @Environment(\.dismiss) private var dismiss
    @State private var nextScreen = false
    
    var body: some View {
        ScrollView {
            SignUpPanel(title: "Personal Information") {
                infoController.clearError()
                dismiss()
            } content: {
                ProfileImagePicker(
                    image: $infoController.employer.profilePicture
                )
                .padding(.top, 18)
                
                VStack(spacing: 10) {
                    AppTextField(
                        title: "First Name",
                        placeholder: "Enter your first name",
                        text: $infoController.employer.firstName
                    )
                    
                    AppTextField(
                        title: "Middle Name",
                        placeholder: "Enter your middle name",
                        text: $infoController.employer.middleName
                    )
                    
                    AppTextField(
                        title: "Last Name",
                        placeholder: "Enter your last name",
                        text: $infoController.employer.lastName
                    )
                    
                    AppTextField(
                        title: "Date of Birth",
                        placeholder: "YYYY-MM-DD",
                        text: $infoController.employer.birthDate,
                        keyboardType: .numbersAndPunctuation
                    )
                    
                    AppTextField(
                        title: "Contact Number",
                        placeholder: "Enter your contact number",
                        text: $infoController.employer.contactNumber,
                        keyboardType: .phonePad
                    )
                    
                    AppTextField(
                        title: "Email Address",
                        placeholder: "e.g., 123@gmail.com",
                        text: $infoController.employer.email,
                        keyboardType: .emailAddress
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }
                .padding(.top, 18)
                
                FormErrorText(message: infoController.signUpError)
                    .padding(.top, 10)
                
                SiriusButton(title: "Continue") {
                    if infoController.validatePersonalInfo() {
                        nextScreen = true
                    }
                }
                .padding(.top, 43)
            }
            .frame(maxWidth: .infinity)
        }
        .ignoresSafeArea(.container, edges: .top)

        .scrollDismissesKeyboard(.interactively)
        .appBg()
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $nextScreen) {
            EmpCompanyInfoPage(infoController: infoController, mode: .signUp)
        }
    }
}

#Preview {
    NavigationStack {
        EmpSignUpPage()
    }
}
