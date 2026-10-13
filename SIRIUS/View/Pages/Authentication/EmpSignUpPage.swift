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
            VStack(spacing: 0) {
                PageHeader(title: "Personal Information") {
                    infoController.clearError()
                    dismiss()
                }
                .padding(.top, 12)
                .padding(.bottom, 30)
                
                ProfileImagePicker(
                    image: $infoController.employer.profilePicture
                )
                .padding(.bottom, 30)
                
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
                
                FormErrorText(message: infoController.signUpError)
                    .padding(.top, 16)
                
                SiriusButton(title: "Continue") {
                    if infoController.validatePersonalInfo() {
                        nextScreen = true
                    }
                }
                .padding(.top, infoController.signUpError == nil ? 60 : 16)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
        }
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
