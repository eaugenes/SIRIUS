//
//  EmpInfoController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/2/26.
//

import Foundation
import Combine
import UIKit

final class EmpInfoController: ObservableObject {
    
    // Saved to the account file whenever a registered employer edits their profile
    @Published var employer: Employer { didSet { persistProfile() } }
    @Published var company: Company { didSet { persistProfile() } }
    @Published var recentActivity: [EmpActivity]
    @Published var isRegistered: Bool = false
    @Published var signUpError: String?
    
    private let auth: AuthController
    
    init(
        employer: Employer = Employer(),
        company: Company = Company(),
        recentActivity: [EmpActivity] = [],
        auth: AuthController = .shared
    ) {
        self.employer = employer
        self.company = company
        self.recentActivity = recentActivity
        self.auth = auth
    }
    
    // Builds the controller for an employer who logged in
    convenience init(account: UserAccount, auth: AuthController = .shared) {
        self.init(
            employer: account.employer ?? Employer(),
            company: account.company ?? Company(),
            auth: auth
        )
        isRegistered = true
    }
    
    private func persistProfile() {
        guard isRegistered else { return }
        let employer = self.employer
        let company = self.company
        Task { await auth.updateEmployer(employer, company: company) }
    }
  
    var displayCompanyName: String {
        let name = company.cmpName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Your Company" : name
    }
    
    var companyInitial: String {
        String(displayCompanyName.prefix(1)).uppercased()
    }
    
    var displayEmail: String {
        let companyEmail = company.email.trimmingCharacters(in: .whitespacesAndNewlines)
        if !companyEmail.isEmpty { return companyEmail }
        return employer.email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func displayValue(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "—" : trimmed
    }
    
    func updateProfile(_ image: UIImage) {
        employer.profilePicture = image
    }
    
    
    // MARK: - Sign up
    
    func validatePersonalInfo() -> Bool {
        if employer.profilePicture == nil {
            signUpError = "Please choose a profile picture."
            return false
        }
        if isBlank(employer.firstName) {
            signUpError = "Please enter your first name."
            return false
        }
        if isBlank(employer.lastName) {
            signUpError = "Please enter your last name."
            return false
        }
        if isBlank(employer.birthDate) {
            signUpError = "Please select your date of birth."
            return false
        }
        if isBlank(employer.contactNumber) {
            signUpError = "Please enter your contact number."
            return false
        }
        
        signUpError = nil
        return true
    }
    
    func validateCompanyInfo(requireAll: Bool = false) -> Bool {
        if isBlank(company.cmpName) {
            signUpError = "Please enter your company name."
            return false
        }
        if requireAll {
            if isBlank(company.cmpDesc) {
                signUpError = "Please enter something about your company."
                return false
            }
            if isBlank(company.founded) {
                signUpError = "Please enter the year your company was founded."
                return false
            }
            if isBlank(company.loc) {
                signUpError = "Please enter your company location."
                return false
            }
        }
        let email = company.email.trimmingCharacters(in: .whitespacesAndNewlines)
        if !email.isEmpty && !isValidEmail(email) {
            signUpError = "Please enter a valid company email address."
            return false
        }
        if requireAll && isBlank(company.website) {
            signUpError = "Please enter your company website."
            return false
        }
        signUpError = nil
        return true
    }
    
    private func isBlank(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    @MainActor
    func sendVerificationCode(confirmPassword: String) async -> Bool {
        switch await auth.sendSignUpCode(email: employer.email, password: employer.password, confirm: confirmPassword) {
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
        switch await auth.resendSignUpCode(email: employer.email) {
        case .failure(let error):
            signUpError = error.errorDescription
            return false
        case .success:
            signUpError = nil
            return true
        }
    }

    @MainActor
    func completeSignUp(confirmPassword: String, code: String) async -> Bool {      // CHANGED: added `code`
        switch await auth.registerEmployer(employer, company: company, password: employer.password, confirm: confirmPassword, code: code) {
        case .failure(let error):
            signUpError = error.errorDescription
            return false
        case .success(let account):
            if let saved = account.employer { employer.id = saved.id; employer.username = saved.username }
            if let savedCompany = account.company { company.id = savedCompany.id }
            employer.password = ""
            signUpError = nil
            isRegistered = true
            return true
        }
    }
    
    func clearError() {
        signUpError = nil
    }
    
    func signOut() {
        isRegistered = false
        auth.signOut()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let at = trimmed.firstIndex(of: "@") else { return false }
        let domain = trimmed[trimmed.index(after: at)...]
        return at != trimmed.startIndex && domain.contains(".") && !trimmed.contains(" ")
    }
    
    // MARK: - Recent activity
    
    // Adds a row to the top of "Recent Activity" (e.g. after posting a job)
    func logActivity(icon: String, title: String, jobPosition: String) {
        recentActivity.insert(
            EmpActivity(icon: icon, title: title, jobPosition: jobPosition, timeAgo: "Just now"),
            at: 0
        )
    }
    
    // MARK: - Sample data
    
    static let sampleActivity: [EmpActivity] = [
        EmpActivity(icon: "person.2", title: "2 New Applicants", jobPosition: "Junior Software Developer", timeAgo: "2 hours ago"),
        EmpActivity(icon: "briefcase", title: "3 Hire Left", jobPosition: "UI/UX Designer", timeAgo: "5 hours ago"),
        EmpActivity(icon: "person.2", title: "5 New Applicants", jobPosition: "UI/UX Designer", timeAgo: "9 hours ago"),
        EmpActivity(icon: "person.2", title: "8 New Applicants", jobPosition: "UI/UX Designer", timeAgo: "1 day ago"),
        EmpActivity(icon: "briefcase", title: "1 Hire Left", jobPosition: "UI/UX Designer", timeAgo: "2 days ago"),
        EmpActivity(icon: "briefcase", title: "3 Hire Left", jobPosition: "UI/UX Designer", timeAgo: "3 days ago")
    ]
    
    // Pre-filled controller for previews
    static func sample() -> EmpInfoController {
        EmpInfoController(
            employer: Employer(firstName: "Sam", lastName: "Reyes", email: "sam@gmail.com"),
            company: Company(
                cmpName: "ABC Company",
                cmpDesc: "ABC Technologies is a leading software development company based in Quezon City. We specialize in enterprise web applications, mobile development, and cloud solutions for businesses across Southeast Asia. We deliver scalable, secure digital transformation that helps businesses optimize operations and accelerate growth.",
                loc: "Lucena City",
                founded: "2015",
                email: "email@gmail.com",
                website: "ABCtech.com.ph"
            ),
            recentActivity: sampleActivity
        )
    }
}
