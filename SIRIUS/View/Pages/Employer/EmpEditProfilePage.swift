//
//  EmpEditProfilePage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI

struct EmpEditProfilePage: View {

    var onClose: (() -> Void)? = nil

    @EnvironmentObject private var infoController: EmpInfoController
    @Environment(\.dismiss) private var dismiss

    @State private var employerDraft = Employer()
    @State private var companyDraft = Company()
    @State private var loaded = false
    @State private var isSaving = false

    var body: some View {
        ScrollView {
            SignUpPanel(title: "Edit Profile") {
                close()
            } content: {
                ProfileImagePicker(
                    image: $employerDraft.profilePicture,
                    defaultAvatar: employerDraft.firstName.defaultAvatar
                )
                .padding(.top, 18)

                VStack(spacing: 10) {
                    sectionTitle("Personal Information")

                    AppTextField(title: "First Name", placeholder: "Enter your first name", text: $employerDraft.firstName)
                    AppTextField(title: "Middle Name", placeholder: "Enter your middle name", text: $employerDraft.middleName)
                    AppTextField(title: "Last Name", placeholder: "Enter your last name", text: $employerDraft.lastName)
                    DateOfBirthField(title: "Date of Birth", text: $employerDraft.birthDate)
                    AppTextField(
                        title: "Contact Number",
                        placeholder: "11 digits, e.g., 09171234567",
                        text: ContactNumber.binding($employerDraft.contactNumber),
                        keyboardType: .numberPad
                    )

                    sectionTitle("Company Information")
                        .padding(.top, 10)

                    AppTextField(title: "Company Name", placeholder: "Enter company name", text: $companyDraft.cmpName)
                    AppTextField(
                        title: "About Company",
                        placeholder: "Enter company about",
                        text: $companyDraft.cmpDesc,
                        isMultiline: true,
                        multilineHeight: 105
                    )
                    AppTextField(title: "Founded", placeholder: "YYYY-MM-DD", text: $companyDraft.founded, keyboardType: .numbersAndPunctuation)
                    AppTextField(title: "Location", placeholder: "Enter company location", text: $companyDraft.loc)
                    AppTextField(title: "Company Email", placeholder: "e.g., hr@company.com", text: $companyDraft.email, keyboardType: .emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    AppTextField(title: "Website", placeholder: "e.g., company.com.ph", text: $companyDraft.website, keyboardType: .URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    FormErrorText(message: infoController.signUpError)
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

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .scaledFont(size: 16, weight: .semibold)
            .foregroundStyle(Color.siriusInk)
            .frame(maxWidth: 300, alignment: .leading)
            .padding(.top, 8)
    }

    private func loadDraft() {
        guard !loaded else { return }
        loaded = true
        infoController.clearError()
        employerDraft = infoController.employer
        companyDraft = infoController.company
    }

    private func close() {
        infoController.clearError()
        if let onClose {
            onClose()
        } else {
            dismiss()
        }
    }

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        Task {
            let saved = await infoController.saveProfile(employer: employerDraft, company: companyDraft)
            isSaving = false
            if saved { close() }
        }
    }
}
