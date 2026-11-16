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
        ScrollView {
            SignUpPanel(title: "Personal Information") {
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
                        placeholder: "11 digits, e.g., 09171234567",
                        text: ContactNumber.binding($infoController.employer.contactNumber),
                        keyboardType: .numberPad
                    )
                }
                .padding(.top, 24)

                Spacer().frame(height: 24)

                FormErrorText(message: infoController.signUpError)
                    .padding(.top, 10)

                SiriusButton(title: "Continue") {
                    if infoController.validatePersonalInfo() {
                        nextScreen = true
                    }
                }
                .padding(.top, 30)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .scrollDismissesKeyboard(.interactively)
        .appBg()
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $nextScreen) {
            EmpCompanyInfoPage(infoController: infoController)
        }
    }
}

#Preview {
    NavigationStack {
        EmpSignUpPage()
    }
}
