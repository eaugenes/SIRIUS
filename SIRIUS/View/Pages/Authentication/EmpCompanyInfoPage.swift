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
// Editing an existing account is done on EmpEditProfilePage (the pencil on the Account screen).
struct EmpCompanyInfoPage: View {
    
    @ObservedObject var infoController: EmpInfoController
    
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Company           // edited copy, saved to the controller on Continue
    @State private var nextScreen = false
    
    init(infoController: EmpInfoController) {
        self.infoController = infoController
        _draft = State(initialValue: infoController.company)
    }
    
    var body: some View {
        // The gradient background (.appBg) is applied to the ScrollView, so it stays fixed while the
        // white Company Information container scrolls on top of it.
        ScrollView {
            SignUpPanel(title: "Company Information") {
                infoController.clearError()
                dismiss()
            } content: {
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
                        title: "Website",
                        placeholder: "e.g., company.com.ph",
                        text: $draft.website,
                        keyboardType: .URL
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }
                .padding(.top, 24)
                
                FormErrorText(message: infoController.signUpError)
                    .padding(.top, 10)
                
                SiriusButton(title: "Continue") {
                    infoController.company = draft
                    
                    guard infoController.validateCompanyInfo(requireAll: true) else { return }
                    nextScreen = true
                }
                .padding(.top, 30)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
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
        EmpCompanyInfoPage(infoController: EmpInfoController())
    }
}
