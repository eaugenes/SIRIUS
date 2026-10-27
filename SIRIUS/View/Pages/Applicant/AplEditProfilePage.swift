//
//  AplEditProfilePage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct AplEditProfilePage: View {
    
    @EnvironmentObject private var applicantController: AplInfoController
    @Environment(\.dismiss) private var dismiss
    
    @State private var years = 0
    @State private var coreLang = ""
    @State private var loaded = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                PageHeader(title: "Edit Profile") {
                    applicantController.clearError()
                    dismiss()
                }
                .padding(.top, 12)
                .padding(.bottom, 20)
                
                ProfileImagePicker(image: $applicantController.applicant.profilePicture)
                    .padding(.bottom, 10)
                
                AppTextField(title: "First Name", placeholder: "Enter your first name", text: $applicantController.applicant.firstName)
                AppTextField(title: "Middle Name", placeholder: "Enter your middle name", text: $applicantController.applicant.middleName)
                AppTextField(title: "Last Name", placeholder: "Enter your last name", text: $applicantController.applicant.lastName)
                AppTextField(title: "Contact Number", placeholder: "Enter your contact number", text: $applicantController.applicant.contactNumber, keyboardType: .phonePad)
                AppTextField(title: "Location", placeholder: "Enter your city", text: $applicantController.applicant.location)
                
                ProgramDropdown(
                    title: "Program",
                    programs: ProgramsList.programs,
                    selectedProgram: $applicantController.applicant.program
                )
                
                AppStepper(title: "Years of Experience", value: $years, range: 0...50)
                
                AppTextField(title: "Core Languages", placeholder: "e.g., Python, C++", text: $coreLang)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                FormErrorText(message: applicantController.signUpError)
                    .padding(.top, 6)
                
                SiriusButton(title: "Save") {
                    applicantController.applicant.yrExp = Double(years)
                    if applicantController.saveProfile(coreLanguageText: coreLang) {
                        dismiss()
                    }
                }
                .padding(.top, applicantController.signUpError == nil ? 30 : 6)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .appBg()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            guard !loaded else { return }
            loaded = true
            years = Int(applicantController.applicant.yrExp.rounded())
            coreLang = applicantController.applicant.coreLang.joined(separator: ", ")
        }
    }
}
