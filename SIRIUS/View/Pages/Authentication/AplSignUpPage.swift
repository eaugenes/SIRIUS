//
//  AplSignUpView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

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
            SignUpPanel(title: "Personal Information") {
                applicantController.clearError()
                dismiss()
            } content: {
                ProfileImagePicker(
                    image: $applicantController.applicant.profilePicture,
                    defaultAvatar: applicantController.applicant.firstName.defaultAvatar
                )
                .padding(.top, 18)
                
                VStack(spacing: 10) {
                    
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
                    
                    DateOfBirthField(
                        title: "Date of Birth",
                        text: $applicantController.applicant.birthDate
                    )
                    
                    AppTextField(
                        title: "Contact Number",
                        placeholder: "Enter your contact number",
                        text: $applicantController.applicant.contactNumber,
                        isSecure: false,
                        keyboardType: .phonePad
                    )
                    
                    CitiesDropdown(
                        title: "Location",
                        cities: cityController.cities,
                        selectedCity: $cityController.selectedCity
                    )
                    
                    ProgramDropdown(
                        title: "Program",
                        programs: ProgramsList.programs,
                        selectedProgram: $applicantController.applicant.program
                    )
                    
                    AppStepper(
                        title: "Years of Experience",
                        value: $yearsOfExperience,
                        range: 0...50,
                        buttonFill: .siriusFieldFill
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
                        selection: $workSetup,
                        selectedFill: .siriusRoleTile,
                        unselectedFill: .siriusFieldFill
                    )
                    
                    FormErrorText(message: applicantController.signUpError)
                        .padding(.top, 10)
                    
                    SiriusButton(title: "Continue") {
                        applicantController.applicant.yrExp = Double(yearsOfExperience)
                        applicantController.applicant.workSetUp = workSetup.rawValue
                        if applicantController.validateProfile(coreLanguageText: coreLang, city: cityController.selectedCity) {
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
                AplFinishSignUpPage(applicantController: applicantController)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AplSignUpPage()
    }
}
