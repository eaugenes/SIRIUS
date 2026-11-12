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
    
    func validateProfile(coreLanguageText: String, city: City?, isSignUp: Bool = false) -> Bool {
        func isBlank(_ s: String) -> Bool { s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if isSignUp && applicant.profilePicture == nil { signUpError = "Please choose a profile picture."; return false }
        if isBlank(applicant.firstName) { signUpError = "Please enter your first name."; return false }
        if isBlank(applicant.lastName)  { signUpError = "Please enter your last name.";  return false }
        
        if isSignUp {
            if isBlank(applicant.birthDate)     { signUpError = "Please select your date of birth.";   return false }
            if isBlank(applicant.contactNumber) { signUpError = "Please enter your contact number.";   return false }
            if city == nil                      { signUpError = "Please select your location.";        return false }
        }
        
        if isBlank(applicant.program) { signUpError = "Please select your program."; return false }
        
        let languages = Matching.parseLanguages(coreLanguageText)
        if languages.isEmpty { signUpError = "Please enter at least one core language."; return false }
        
        if isSignUp, isBlank(applicant.workSetUp) { signUpError = "Please select your work setup."; return false }
        
        if applicant.yrExp < 0 { signUpError = "Years of experience can't be negative."; return false }
        
        guard validateProjects() else { return false }
        
        applicant.coreLang = languages
        applicant.program = ProgramCatalog.complete(applicant.program)
        applicant.location = city?.name ?? applicant.location
        signUpError = nil
        return true
    }
    
    // Projects are optional, but every project that is kept needs a title and a description.
    // Projects with nothing in them are dropped; a half-filled project blocks the user until it is
    // completed or removed.
    private func validateProjects() -> Bool {
        applicant.projects.removeAll { $0.isBlank }
        
        for (index, project) in applicant.projects.enumerated() {
            let number = index + 1
            if project.trimmedTitle.isEmpty {
                signUpError = "Project \(number) needs a title. Add one or remove the project."
                return false
            }
            if project.trimmedDetails.isEmpty {
                signUpError = "Project \(number) needs a description. Add one or remove the project."
                return false
            }
            if project.title.count > Project.titleLimit || project.details.count > Project.descriptionLimit {
                signUpError = "Project \(number) is too long. Title: \(Project.titleLimit) characters, description: \(Project.descriptionLimit)."
                return false
            }
        }
        
        for index in applicant.projects.indices {
            applicant.projects[index].title = applicant.projects[index].trimmedTitle
            applicant.projects[index].details = applicant.projects[index].trimmedDetails
        }
        return true
    }
    
    @MainActor
    func sendVerificationCode(confirmPassword: String) async -> Bool {
        switch await auth.sendSignUpCode(email: applicant.email, password: applicant.password, confirm: confirmPassword) {
        case .failure(let error):
            signUpError = error.errorDescription
            return false
        case .success:
            signUpError = nil
            return true
        }
    }

    @MainActor
    func resendVerificationCode() async -> Bool {
        switch await auth.resendSignUpCode(email: applicant.email) {
        case .failure(let error):
            signUpError = error.errorDescription
            return false
        case .success:
            signUpError = nil
            return true
        }
    }

    @MainActor
    func completeSignUp(confirmPassword: String, code: String) async -> Bool {
        switch await auth.registerApplicant(applicant, password: applicant.password, confirm: confirmPassword, code: code) {
        case .failure(let error):
            signUpError = error.errorDescription
            return false
        case .success(let account):
            if let saved = account.applicant {
                applicant.id = saved.id
                applicant.email = saved.email
                applicant.username = saved.username
                applicant.projects = saved.projects         // now holds the uploaded picture paths
            }
            applicant.password = ""
            isRegistered = true
            signUpError = nil
            await board.applyToQualifiedJobs(applicant: applicant)
            return true
        }
    }
    
    // MARK: - Profile editing
    
    // Saves the edited copy of the profile. On any problem the previous profile stays in place and
    // `signUpError` says what went wrong.
    @MainActor
    func saveProfile(_ draft: Applicant, coreLanguageText: String, city: City?) async -> Bool {
        let original = applicant
        applicant = draft
        guard validateProfile(coreLanguageText: coreLanguageText, city: city) else {
            applicant = original
            return false
        }
        guard let saved = await auth.updateApplicant(applicant) else {
            applicant = original
            signUpError = AccountError.saveFailed.errorDescription
            return false
        }
        applicant = saved
        await board.reload(silent: true)
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
