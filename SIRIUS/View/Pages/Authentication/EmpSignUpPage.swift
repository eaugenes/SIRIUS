//
//  EmpSignUpView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/10/26.
//

import SwiftUI

struct EmpSignUpPage: View {
    @StateObject private var infoController = EmpInfoController()
    @Environment(\.dismiss) private var dismiss
    @State private var nextScreen = false
    
    var body: some View {
        GeometryReader { geo in
            // same gap as between the panel and the sides of the phone
            let sideGap = max((geo.size.width - 365) / 2, 0)
            
            SignUpPanel(title: "Personal Information", fillsScreen: true, bottomGap: sideGap) {
                infoController.clearError()
                dismiss()
            } content: {
                ProfileImagePicker(
                    image: $infoController.employer.profilePicture,
                    defaultAvatar: infoController.employer.firstName.defaultAvatar
                )
                .padding(.top, 28)
                
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
                    
                    DateOfBirthField(
                        title: "Date of Birth",
                        text: $infoController.employer.birthDate
                    )
                    
                    AppTextField(
                        title: "Contact Number",
                        placeholder: "Enter your contact number",
                        text: $infoController.employer.contactNumber,
                        keyboardType: .phonePad
                    )
                }
                .padding(.top, 24)
                
                FormErrorText(message: infoController.signUpError)
                    .padding(.top, 10)
                
                Spacer(minLength: 16)
                
                SiriusButton(title: "Continue") {
                    if infoController.validatePersonalInfo() {
                        nextScreen = true
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.container)
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
