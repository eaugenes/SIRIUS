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
    
    @Published var employer: Employer
    @Published var company: Company
    @Published var recentActivity: [EmpActivity]
    @Published var isRegistered: Bool = false
    @Published var signUpError: String?
    
    init(
        employer: Employer = Employer(),
        company: Company = Company(),
        recentActivity: [EmpActivity] = EmpInfoController.sampleActivity
    ) {
        self.employer = employer
        self.company = company
        self.recentActivity = recentActivity
    }
    
    // MARK: - Display helpers
    
    var displayCompanyName: String {
        let name = company.cmpName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Your Company" : name
    }
    
    var companyInitial: String {
        String(displayCompanyName.prefix(1)).uppercased()
    }
    
    // Company email first, then the employer's personal email
    var displayEmail: String {
        let companyEmail = company.email.trimmingCharacters(in: .whitespacesAndNewlines)
        if !companyEmail.isEmpty { return companyEmail }
        return employer.email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Shows "—" for empty fields on the Account screen
    func displayValue(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "—" : trimmed
    }
    
    // MARK: - Profile picture
    
    func updateProfile(_ image: UIImage) {
        employer.profilePicture = image
    }
    
    // MARK: - Sign up (3 steps)
    
    // Step 1: Personal Information
    func validatePersonalInfo() -> Bool {
        if employer.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            signUpError = "Please enter your first name."
            return false
        }
        if employer.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            signUpError = "Please enter your last name."
            return false
        }
        if !isValidEmail(employer.email) {
            signUpError = "Please enter a valid email address."
            return false
        }
        signUpError = nil
        return true
    }
    
    // Step 2: Company Information (also used when editing from the Account screen)
    func validateCompanyInfo() -> Bool {
        if company.cmpName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            signUpError = "Please enter your company name."
            return false
        }
        let email = company.email.trimmingCharacters(in: .whitespacesAndNewlines)
        if !email.isEmpty && !isValidEmail(email) {
            signUpError = "Please enter a valid company email address."
            return false
        }
        signUpError = nil
        return true
    }
    
    // Step 3: Finish Sign Up. Returns true when registration succeeded.
    func completeSignUp(confirmPassword: String) -> Bool {
        let username = employer.username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if username.isEmpty {
            signUpError = "Please enter a username."
            return false
        }
        if employer.password.isEmpty {
            signUpError = "Please enter a password."
            return false
        }
        if employer.password != confirmPassword {
            signUpError = "Passwords do not match."
            return false
        }
        
        employer.username = username
        signUpError = nil
        isRegistered = true
        return true
    }
    
    func clearError() {
        signUpError = nil
    }
    
    func signOut() {
        isRegistered = false
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
            )
        )
    }
}
