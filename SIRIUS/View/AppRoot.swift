//
//  AppRoot.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/17/26.
//

import Combine
import SwiftUI

struct AppRoot: View {

    @ObservedObject private var auth = AuthController.shared
    @State private var isRestoring = true

    var body: some View {
        Group {
            if let account = auth.currentAccount {
                SignedInRoot(account: account)
                    .id(account.id)
            } else if isRestoring {
                ProgressView()
                    .tint(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .appBg()
            } else {
                LogInPage()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: auth.currentAccount?.id)
        .animation(.easeInOut(duration: 0.25), value: isRestoring)
        .task {
            _ = await auth.restoreSession()
            isRestoring = false
        }
    }
}

private struct SignedInRoot: View {

    let role: UserRole

    @StateObject private var applicantController: AplInfoController
    @StateObject private var employerController: EmpInfoController

    init(account: UserAccount) {
        role = account.role
        _applicantController = StateObject(wrappedValue: account.role == .applicant
            ? AplInfoController(account: account)
            : AplInfoController(applicant: AplInfoController.blankApplicant()))
        _employerController = StateObject(wrappedValue: account.role == .employer
            ? EmpInfoController(account: account)
            : EmpInfoController())
    }

    var body: some View {
        MainTabView(role: role, infoController: employerController, applicantController: applicantController)
    }
}
