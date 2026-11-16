//
//  EmpCompanyInfoPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/13/26.
//

import SwiftUI
import UIKit

struct EmpCompanyInfoPage: View {

    @ObservedObject var infoController: EmpInfoController

    @Environment(\.dismiss) private var dismiss
    @State private var draft: Company
    @State private var nextScreen = false

    init(infoController: EmpInfoController) {
        self.infoController = infoController
        _draft = State(initialValue: infoController.company)
    }

    var body: some View {
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

                Spacer().frame(height: 24)

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
