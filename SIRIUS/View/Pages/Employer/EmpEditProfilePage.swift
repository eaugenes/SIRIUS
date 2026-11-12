//
//  EmpEditProfilePage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import SwiftUI

struct EmpEditProfilePage: View {
    
    @EnvironmentObject private var infoController: EmpInfoController
    @Environment(\.dismiss) private var dismiss
    
    @State private var employerDraft = Employer()
    @State private var companyDraft = Company()
    @State private var loaded = false
    @State private var isSaving = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                PageHeader(title: "Edit Profile", titleColor: .white) {
                    infoController.clearError()
                    dismiss()
                }
                .padding(.top, 12)
                .padding(.bottom, 20)
                
                ProfileImagePicker(
                    image: $employerDraft.profilePicture,
                    defaultAvatar: companyDraft.cmpName.defaultAvatar
                )
                
                sectionTitle("Personal Information")
                
                AppTextField(title: "First Name", placeholder: "Enter your first name", text: $employerDraft.firstName)
                AppTextField(title: "Middle Name", placeholder: "Enter your middle name", text: $employerDraft.middleName)
                AppTextField(title: "Last Name", placeholder: "Enter your last name", text: $employerDraft.lastName)
                DateOfBirthField(title: "Date of Birth", text: $employerDraft.birthDate)
                AppTextField(title: "Contact Number", placeholder: "Enter your contact number", text: $employerDraft.contactNumber, keyboardType: .phonePad)
                
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
                    .padding(.top, 6)
                
                SiriusButton(title: isSaving ? "Saving\u{2026}" : "Save") {
                    save()
                }
                .disabled(isSaving)
                .padding(.top, infoController.signUpError == nil ? 30 : 6)
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
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .scaledFont(size: 16, weight: .semibold)
            .foregroundStyle(Color.siriusText)
            .frame(maxWidth: 300, alignment: .leading)
            .padding(.top, 8)
    }
    
    // Copies the saved profile into the form (once)
    private func loadDraft() {
        guard !loaded else { return }
        loaded = true
        employerDraft = infoController.employer
        companyDraft = infoController.company
    }
    
    private func save() {
        guard !isSaving else { return }
        isSaving = true
        Task {
            if await infoController.saveProfile(employer: employerDraft, company: companyDraft) {
                dismiss()
            }
            isSaving = false
        }
    }
}
