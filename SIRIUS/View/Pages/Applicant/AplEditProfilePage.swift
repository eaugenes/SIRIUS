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
    
    @State private var draft = AplInfoController.blankApplicant()
    @State private var years = 0
    @State private var coreLang = ""
    @State private var workSetup: WorkSetup = .onSite
    @State private var selectedCity: City?
    @State private var loaded = false
    @State private var isSaving = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                PageHeader(title: "Edit Profile", titleColor: .white) {
                    applicantController.clearError()
                    dismiss()
                }
                .padding(.top, 12)
                .padding(.bottom, 20)
                
                ProfileImagePicker(
                    image: $draft.profilePicture,
                    defaultAvatar: draft.firstName.defaultAvatar
                )
                
                AppTextField(title: "First Name", placeholder: "Enter your first name", text: $draft.firstName)
                AppTextField(title: "Middle Name", placeholder: "Enter your middle name", text: $draft.middleName)
                AppTextField(title: "Last Name", placeholder: "Enter your last name", text: $draft.lastName)
                
                DateOfBirthField(title: "Date of Birth", text: $draft.birthDate)
                
                AppTextField(title: "Contact Number", placeholder: "Enter your contact number", text: $draft.contactNumber, keyboardType: .phonePad)
                
                CitiesDropdown(
                    title: "Location",
                    cities: CalabarzonCitiesData.cities,
                    selectedCity: $selectedCity
                )
                
                ProgramDropdown(
                    title: "Program",
                    programs: ProgramsList.programs,
                    selectedProgram: $draft.program
                )
                
                AppStepper(title: "Years of Experience", value: $years, range: 0...50)
                
                AppTextField(title: "Core Languages", placeholder: "e.g., Python, C++", text: $coreLang)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                WorkSetupPicker(
                    title: "Work Setup",
                    selection: $workSetup,
                    selectedFill: .siriusRoleTile,
                    unselectedFill: .siriusFieldFill
                )
                
                ProjectsEditor(projects: $draft.projects)
                    .padding(.top, 4)
                
                FormErrorText(message: applicantController.signUpError)
                    .padding(.top, 6)
                
                SiriusButton(title: isSaving ? "Saving\u{2026}" : "Save") {
                    save()
                }
                .disabled(isSaving)
                .padding(.top, applicantController.signUpError == nil ? 30 : 6)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .appBg()
        .navigationBarBackButtonHidden(true)
        .hidesSiriusNavBar()
        .onAppear { loadDraft() }
    }
    
    // Copies the saved profile into the form (once)
    private func loadDraft() {
        guard !loaded else { return }
        loaded = true
        let saved = applicantController.applicant
        draft = saved
        years = Int(saved.yrExp.rounded())
        coreLang = saved.coreLang.joined(separator: ", ")
        workSetup = WorkSetup(rawValue: saved.workSetUp) ?? .onSite
        selectedCity = CalabarzonCitiesData.cities.first {
            Matching.normalized($0.name) == Matching.normalized(saved.location)
        }
    }
    
    private func save() {
        guard !isSaving else { return }
        isSaving = true
        draft.yrExp = Double(years)
        draft.workSetUp = workSetup.rawValue
        Task {
            if await applicantController.saveProfile(draft, coreLanguageText: coreLang, city: selectedCity) {
                dismiss()
            }
            isSaving = false
        }
    }
}
