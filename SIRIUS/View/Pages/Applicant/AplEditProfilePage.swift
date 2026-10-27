//
//  AplEditProfilePage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct AplEditProfilePage: View {
    
    @EnvironmentObject private var applicantController: AplInfoController
    @Environment(\.dismiss) private var dismiss
    
    @State private var years = 0
    @State private var coreLang = ""
    @State private var loaded = false
    @State private var pickingResume = false
    
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
                
                resumeSection
                
                FormErrorText(message: applicantController.signUpError)
                    .padding(.top, 6)
                
                SiriusButton(title: "Save") {
                    applicantController.applicant.yrExp = Double(years)
                    Task {
                        if await applicantController.saveProfile(coreLanguageText: coreLang) {
                            dismiss()
                        }
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
        .fileImporter(isPresented: $pickingResume, allowedContentTypes: Self.resumeTypes) { result in
            if case .success(let url) = result {
                applicantController.setResume(from: url)
            }
        }
        .onAppear {
            guard !loaded else { return }
            loaded = true
            years = Int(applicantController.applicant.yrExp.rounded())
            coreLang = applicantController.applicant.coreLang.joined(separator: ", ")
        }
    }
    
    private static let resumeTypes: [UTType] = [
        .pdf, .plainText, .rtf,
        UTType("org.openxmlformats.wordprocessingml.document"),
        UTType("com.microsoft.word.doc")
    ].compactMap { $0 }
    
    // Resume (PDF, Word or text, up to 5 MB). Employers see the file name on your application.
    private var resumeSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Resume")
                .scaledFont(size: 13, weight: .medium)
                .foregroundStyle(Color.siriusInk)
                .padding(.leading, 11)
            
            HStack(spacing: 10) {
                Image(systemName: "doc.text")
                    .foregroundStyle(Color.siriusAction)
                Text(applicantController.applicant.resumeFileName.isEmpty
                     ? "No resume uploaded"
                     : applicantController.applicant.resumeFileName)
                    .scaledFont(size: 14, weight: .light)
                    .foregroundStyle(Color.siriusTextSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                if !applicantController.applicant.resumeFileName.isEmpty {
                    Button {
                        applicantController.removeResume()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(Color.siriusDanger)
                    }
                    .accessibilityLabel("Remove resume")
                }
                Button(applicantController.applicant.resumeFileName.isEmpty ? "Upload" : "Replace") {
                    pickingResume = true
                }
                .scaledFont(size: 13, weight: .semibold)
                .foregroundStyle(Color.siriusAction)
            }
            .padding(.horizontal, 10)
            .frame(width: 300, height: 40)
            .background(Color.siriusFieldFill)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.siriusFieldBorder, lineWidth: 1))
        }
    }
}
