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
        applicant.program = ProgramCatalog.complete(applicant.program)      // "BS CS" -> "BS Computer Science"
        applicant.location = city?.name ?? applicant.location
        signUpError = nil
        return true
    }
    
    // Step 2: password. Creates the Supabase account, then asks the server to apply the applicant to every matching job.
    @MainActor
    func completeSignUp(confirmPassword: String) async -> Bool {
        switch await auth.registerApplicant(applicant, password: applicant.password, confirm: confirmPassword) {
        case .failure(let error):
            signUpError = error.errorDescription
            return false
        case .success(let account):
            if let saved = account.applicant {
                applicant.id = saved.id                 // the applicant id is the Supabase user id
                applicant.email = saved.email
                applicant.username = saved.username
            }
            applicant.password = ""
            isRegistered = true
            signUpError = nil
            await board.autoApply(applicant: applicant)
            return true
        }
    }
    
    // MARK: - Profile editing
    
    // Saves edits, then asks the server to apply the applicant to any job they now match.
    @MainActor
    func saveProfile(coreLanguageText: String) async -> Bool {
        guard validateProfile(coreLanguageText: coreLanguageText, city: nil) else { return false }
        guard await auth.updateApplicant(applicant) else {
            signUpError = AccountError.saveFailed.errorDescription
            return false
        }
        await board.autoApply(applicant: applicant)
        return true
    }
    
    // MARK: - Resume
    
    static let maxResumeBytes = 5 * 1024 * 1024
    
    // Keeps the picked file in memory. TODO(Supabase Storage): upload `data` to a bucket and save the path.
    @discardableResult
    func setResume(from url: URL) -> Bool {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
        
        guard let data = try? Data(contentsOf: url) else {
            signUpError = "That file couldn't be opened. Please choose another one."
            return false
        }
        guard data.count <= AplInfoController.maxResumeBytes else {
            signUpError = "Resume must be 5 MB or smaller."
            return false
        }
        applicant.resumeData = data
        applicant.resumeFileName = url.lastPathComponent
        signUpError = nil
        return true
    }
    
    func removeResume() {
        applicant.resumeData = nil
        applicant.resumeFileName = ""
    }
    
    func signOut() {
        isRegistered = false
        auth.signOut()
    }
    
    func clearError() {
        signUpError = nil
    }
}
