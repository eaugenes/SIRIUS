//
//  AplEditProfilePage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct AplEditProfilePage: View {

    var onClose: (() -> Void)? = nil

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
            SignUpPanel(title: "Edit Profile") {
                close()
            } content: {
                ProfileImagePicker(
                    image: $draft.profilePicture,
                    defaultAvatar: draft.firstName.defaultAvatar
                )
                .padding(.top, 18)

                VStack(spacing: 10) {
                    AppTextField(title: "First Name", placeholder: "Enter your first name", text: $draft.firstName)
                    AppTextField(title: "Middle Name", placeholder: "Enter your middle name", text: $draft.middleName)
                    AppTextField(title: "Last Name", placeholder: "Enter your last name", text: $draft.lastName)

                    DateOfBirthField(title: "Date of Birth", text: $draft.birthDate)

                    AppTextField(
                        title: "Contact Number",
                        placeholder: "11 digits, e.g., 09171234567",
                        text: ContactNumber.binding($draft.contactNumber),
                        keyboardType: .numberPad
                    )

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

                    AppStepper(title: "Years of Experience", value: $years, range: 0...50, buttonFill: .siriusFieldFill)

                    AppTextField(title: "Core Languages", placeholder: "e.g., Python, C++", text: $coreLang)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    WorkSetupPicker(
                        title: "Work Setup",
                        selection: $workSetup,
                        selectedFill: .siriusRoleTile,
                        unselectedFill: .siriusFieldFill
                    )

                    AppTextField(
                        title: "GitHub Link (optional)",
                        placeholder: ProfileLink.Kind.github.placeholder,
                        text: $draft.githubURL,
                        isSecure: false,
                        keyboardType: .URL
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    AppTextField(
                        title: "LinkedIn Link (optional)",
                        placeholder: ProfileLink.Kind.linkedin.placeholder,
                        text: $draft.linkedinURL,
                        isSecure: false,
                        keyboardType: .URL
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    ProjectsEditor(projects: $draft.projects)
                        .padding(.top, 4)

                    FormErrorText(message: applicantController.signUpError)
                        .padding(.top, 10)

                    SiriusButton(title: isSaving ? "Saving\u{2026}" : "Save") {
                        save()
                    }
                    .disabled(isSaving)
                    .padding(.top, 30)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .scrollDismissesKeyboard(.interactively)
        .appBg()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .hidesSiriusNavBar()
        .onAppear { loadDraft() }
    }

    private func loadDraft() {
        guard !loaded else { return }
        loaded = true
        applicantController.clearError()
        let saved = applicantController.applicant
        draft = saved
        years = Int(saved.yrExp.rounded())
        coreLang = saved.coreLang.joined(separator: ", ")
        workSetup = WorkSetup(rawValue: saved.workSetUp) ?? .onSite
        selectedCity = CalabarzonCitiesData.cities.first {
            Matching.normalized($0.name) == Matching.normalized(saved.location)
        }
    }

    private func close() {
        applicantController.clearError()
        if let onClose {
            onClose()
        } else {
            dismiss()
        }
    }

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        draft.yrExp = Double(years)
        draft.workSetUp = workSetup.rawValue
        Task { @MainActor in
            let saved = await applicantController.saveProfile(draft, coreLanguageText: coreLang, city: selectedCity)
            isSaving = false
            if saved { close() }
        }
    }
}
