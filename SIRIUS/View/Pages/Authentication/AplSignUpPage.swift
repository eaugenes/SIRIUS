//
//  AplSignUpView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

// Applicant sign up — step 1 of 2: Personal Information + qualifications
// (the qualifications are what jobs are matched against)
struct AplSignUpPage: View {
    
    @StateObject private var applicantController = AplInfoController(
        applicant: AplInfoController.blankApplicant()
    )
    @StateObject private var cityController = CitySelectionController()
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var coreLang = ""
    @State private var yearsOfExperience = 0
    @State private var workSetup: WorkSetup = .onSite
    @State private var nextScreen = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                PageHeader(title: "Personal Information") {
                    applicantController.clearError()
                    dismiss()
                }
                .padding(.top, 12)
                .padding(.bottom, 20)
                
                ProfileImagePicker(
                    image: $applicantController.applicant.profilePicture
                )
                .padding(.bottom, 10)
                
                AppTextField(
                    title: "First Name",
                    placeholder: "Enter your first name",
                    text: $applicantController.applicant.firstName,
                    isSecure: false
                )
                
                AppTextField(
                    title: "Middle Name",
                    placeholder: "Enter your middle name",
                    text: $applicantController.applicant.middleName,
                    isSecure: false
                )
                
                AppTextField(
                    title: "Last Name",
                    placeholder: "Enter your last name",
                    text: $applicantController.applicant.lastName,
                    isSecure: false
                )
                
                AppTextField(
                    title: "Date of Birth",
                    placeholder: "YYYY-MM-DD",
                    text: $applicantController.applicant.birthDate,
                    isSecure: false,
                    keyboardType: .numbersAndPunctuation
                )
                
                AppTextField(
                    title: "Contact Number",
                    placeholder: "Enter your contact number",
                    text: $applicantController.applicant.contactNumber,
                    isSecure: false,
                    keyboardType: .phonePad
                )
                
                AppTextField(
                    title: "Email Address",
                    placeholder: "e.g., 123@gmail.com",
                    text: $applicantController.applicant.email,
                    keyboardType: .emailAddress
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                
                CitiesDropdown(
                    title: "Location",
                    cities: cityController.cities,
                    selectedCity: $cityController.selectedCity
                )
                .zIndex(1)
                
                ProgramDropdown(
                    title: "Program",
                    programs: ProgramsList.programs,
                    selectedProgram: $applicantController.applicant.program
                )
                
                AppStepper(
                    title: "Years of Experience",
                    value: $yearsOfExperience,
                    range: 0...50
                )
                
                AppTextField(
                    title: "Core Languages",
                    placeholder: "e.g., Python, C++",
                    text: $coreLang,
                    isSecure: false
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                
                WorkSetupPicker(
                    title: "Work Setup",
                    selection: $workSetup
                )
                
                FormErrorText(message: applicantController.signUpError)
                    .padding(.top, 6)
                
                SiriusButton(title: "Continue") {
                    applicantController.applicant.yrExp = Double(yearsOfExperience)
                    applicantController.applicant.workSetUp = workSetup.rawValue
                    if applicantController.validateProfile(coreLanguageText: coreLang, city: cityController.selectedCity) {
                        nextScreen = true
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
        .navigationDestination(isPresented: $nextScreen) {
            AplFinishSignUpPage(applicantController: applicantController)
        }
    }
}

#Preview {
    NavigationStack {
        AplSignUpPage()
    }
}
