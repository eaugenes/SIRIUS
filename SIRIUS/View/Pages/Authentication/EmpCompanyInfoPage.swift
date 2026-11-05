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
        GeometryReader { geo in
            // same gap as between the panel and the sides of the phone
            let sideGap = max((geo.size.width - 365) / 2, 0)
            
            SignUpPanel(title: "Company Information", fillsScreen: true, bottomGap: sideGap) {
                infoController.clearError()
                dismiss()
            } content: {
                Spacer(minLength: 12)
                
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
                
                FormErrorText(message: infoController.signUpError)
                    .padding(.top, 10)
                
                Spacer(minLength: 16)
                
                SiriusButton(title: mode == .signUp ? "Continue" : "Save") {
                    infoController.company = draft
                    
                    guard infoController.validateCompanyInfo(requireAll: mode == .signUp) else { return }
                    switch mode {
                    case .signUp: nextScreen = true
                    case .edit: dismiss()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.container)
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
