//
//  ApplicantController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/11/26.
//

import Foundation
import Combine          // for ObservableObject and @Published
import UIKit            // UIImage()

class AplInfoController: ObservableObject{
    
    @Published var applicant: Applicant
    @Published var signUpError: String?
    
    private let auth: AuthController
    private let board: JobBoard
    private var isRegistered = false
    
    init(applicant: Applicant, auth: AuthController = .shared, board: JobBoard = .shared) {
        self.applicant = applicant
        self.auth = auth
        self.board = board
    }
    
    // Builds the controller for an applicant who logged in
    convenience init(account: UserAccount, auth: AuthController = .shared, board: JobBoard = .shared) {
        self.init(
            applicant: account.applicant ?? AplInfoController.blankApplicant(),
            auth: auth,
            board: board
        )
        isRegistered = true
    }
    
    static func blankApplicant() -> Applicant {
        Applicant(
            firstName: "", middleName: "", lastName: "", contactNumber: "", location: "",
            program: "", yrExp: 0.0, coreLang: [], workSetUp: "", email: "", password: ""
        )
    }
    
    func updateProfile(_ image: UIImage) {
        applicant.profilePicture = image
    }
    
    // MARK: - Sign up
    
    // Step 1: personal + qualification details. Stores the parsed languages and city on the applicant.
    func validateProfile(coreLanguageText: String, city: City?) -> Bool {
        if applicant.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            signUpError = "Please enter your first name."
            return false
        }
        if applicant.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            signUpError = "Please enter your last name."
            return false
        }
        if applicant.program.isEmpty {
            signUpError = "Please select your program."
            return false
        }
        let languages = Matching.parseLanguages(coreLanguageText)
        if languages.isEmpty {
            signUpError = "Please enter at least one core language."
            return false
        }
        if applicant.yrExp < 0 {
            signUpError = "Years of experience can't be negative."
            return false
        }
        applicant.coreLang = languages
        applicant.location = city?.name ?? applicant.location
        signUpError = nil
        return true
    }
    
    // Step 2: username + password. Saves the account, then applies the applicant to every matching job.
    func completeSignUp(confirmPassword: String) -> Bool {
        switch auth.registerApplicant(applicant, password: applicant.password, confirm: confirmPassword) {
        case .failure(let error):
            signUpError = error.errorDescription
            return false
        case .success(let account):
            applicant.username = account.username
            applicant.password = ""
            isRegistered = true
            board.autoApply(applicant: applicant)
            signUpError = nil
            return true
        }
    }
    
    // MARK: - Profile editing
    
    // Saves edits and applies the applicant to any job they now match.
    func saveProfile(coreLanguageText: String) -> Bool {
        guard validateProfile(coreLanguageText: coreLanguageText, city: nil) else { return false }
        guard auth.updateApplicant(applicant) else {
            signUpError = AuthError.saveFailed.errorDescription
            return false
        }
        board.autoApply(applicant: applicant)
        return true
    }
    
    func signOut() {
        isRegistered = false
        auth.signOut()
    }
    
    func clearError() {
        signUpError = nil
    }
}
