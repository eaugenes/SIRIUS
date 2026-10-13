//
//  EmpCompanyInfoPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/13/26.
//

import SwiftUI
import UIKit           // UIKeyboardType / UIImage

// Employer sign up — step 2 of 3: Company Information
// (Figma: Continue Sign Up Screen (Employer))
// Also reused from the employer Account screen (pencil button) to edit the company.
struct EmpCompanyInfoPage: View {
    
    enum Mode {
        case signUp     // "Continue" → Finish Sign Up
        case edit       // "Save" → back to Account
    }
    
    @ObservedObject var infoController: EmpInfoController
    let mode: Mode
    
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Company           // edited copy, saved to the controller on Continue/Save
    @State private var nextScreen = false
    
    init(infoController: EmpInfoController, mode: Mode) {
        self.infoController = infoController
        self.mode = mode
        _draft = State(initialValue: infoController.company)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                PageHeader(title: "Company Information") {
                    infoController.clearError()
                    dismiss()
                }
                .padding(.top, 12)
                .padding(.bottom, 80)
                
                VStack(spacing: 10) {
                    AppTextField(
                        title: "Company Name",
                        placeholder: "Enter company name",
                        text: $draft.cmpName
                    )
                    
                    AppTextField(
                        title: "About Company",
                        placeholder: "Enter company about",
                        text: $draft.cmpDesc,
                        isMultiline: true,
                        multilineHeight: 105
                    )
                    
                    AppTextField(
                        title: "Founded",
                        placeholder: "YYYY-MM-DD",
                        text: $draft.founded,
                        keyboardType: .numbersAndPunctuation
                    )
                    
                    AppTextField(
                        title: "Location",
                        placeholder: "Enter company location",
                        text: $draft.loc
                    )
                    
                    AppTextField(
                        title: "Email Address",
                        placeholder: "e.g., 123@gmail.com",
                        text: $draft.email,
                        keyboardType: .emailAddress
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    
                    AppTextField(
                        title: "Website",
                        placeholder: "e.g., company.com.ph",
                        text: $draft.website,
                        keyboardType: .URL
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }
                
                FormErrorText(message: infoController.signUpError)
                    .padding(.top, 16)
                
                SiriusButton(title: mode == .signUp ? "Continue" : "Save") {
                    infoController.company = draft
                    
                    guard infoController.validateCompanyInfo() else { return }
                    
                    switch mode {
                    case .signUp: nextScreen = true
                    case .edit: dismiss()
                    }
                }
                .padding(.top, infoController.signUpError == nil ? 60 : 16)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .appBg()
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $nextScreen) {
            EmpFinishSignUpPage(infoController: infoController)
        }
    }
}

#Preview {
    NavigationStack {
        EmpCompanyInfoPage(infoController: EmpInfoController(), mode: .signUp)
    }
}
