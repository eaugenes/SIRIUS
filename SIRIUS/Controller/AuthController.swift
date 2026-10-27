//
//  AuthController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation
import Combine

// Sign up / log in / log out against Supabase Auth (email + password).
// Passwords are sent to Supabase only; the app never stores them.
final class AuthController: ObservableObject {
    
    static let shared = AuthController()
    
    @Published private(set) var currentAccount: UserAccount?
    
    private var didRestoreSession = false
    
    init() {}
    
    // MARK: - Validation
    
    static let minimumPasswordLength = 6
    
    static func normalizedEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let at = trimmed.firstIndex(of: "@") else { return false }
        let domain = trimmed[trimmed.index(after: at)...]
        return at != trimmed.startIndex && domain.contains(".") && !domain.hasSuffix(".") && !trimmed.contains(" ")
    }
    
    func validateCredentials(email: String, password: String, confirm: String) -> AccountError? {
        let address = Self.normalizedEmail(email)
        if address.isEmpty { return .missingEmail }
        if !Self.isValidEmail(address) { return .invalidEmail }
        if password.isEmpty { return .missingPassword }
        if password.count < Self.minimumPasswordLength { return .weakPassword }
        if password != confirm { return .passwordMismatch }
        return nil
    }
    
    // MARK: - Sign up
    
    @MainActor
    func registerApplicant(_ applicant: Applicant, password: String, confirm: String) async -> Result<UserAccount, AccountError> {
        if let error = validateCredentials(email: applicant.email, password: password, confirm: confirm) {
            return .failure(error)
        }
        let email = Self.normalizedEmail(applicant.email)
        do {
            let result = try await SupabaseAuthService.signUp(email: email, password: password, role: .applicant)
            if result.needsEmailConfirmation { return .failure(.confirmEmail) }
            
            var profile = applicant
            profile.id = result.userID                  // the applicant id IS the Supabase user id
            profile.email = email
            profile.password = ""                       // never kept
            profile.username = email.split(separator: "@").first.map(String.init) ?? ""
            try await SupabaseStore.saveApplicant(profile)
            
            let account = UserAccount(id: result.userID, role: .applicant, email: email, applicant: profile)
            currentAccount = account
            return .success(account)
        } catch {
            return .failure(SupabaseAuthService.accountError(from: error))
        }
    }
    
    @MainActor
    func registerEmployer(_ employer: Employer, company: Company, password: String, confirm: String) async -> Result<UserAccount, AccountError> {
        if let error = validateCredentials(email: employer.email, password: password, confirm: confirm) {
            return .failure(error)
        }
        let email = Self.normalizedEmail(employer.email)
        do {
            let result = try await SupabaseAuthService.signUp(email: email, password: password, role: .employer)
            if result.needsEmailConfirmation { return .failure(.confirmEmail) }
            
            var profile = employer
            profile.id = result.userID
            profile.email = email
            profile.password = ""
            profile.username = email.split(separator: "@").first.map(String.init) ?? ""
            var companyProfile = company
            companyProfile.id = result.userID.uuidString.lowercased()      // the company id IS the employer's user id
            try await SupabaseStore.saveEmployer(profile, company: companyProfile, userID: result.userID)
            
            let account = UserAccount(id: result.userID, role: .employer, email: email, employer: profile, company: companyProfile)
            currentAccount = account
            return .success(account)
        } catch {
            return .failure(SupabaseAuthService.accountError(from: error))
        }
    }
    
    // MARK: - Log in / out
    
    @MainActor
    func login(email: String, password: String) async -> Result<UserAccount, AccountError> {
        let address = Self.normalizedEmail(email)
        if address.isEmpty { return .failure(.missingEmail) }
        if password.isEmpty { return .failure(.missingPassword) }
        do {
            let profile = try await SupabaseAuthService.signIn(email: address, password: password)
            let account = try await loadAccount(profile, fallbackEmail: address)
            currentAccount = account
            return .success(account)
        } catch {
            return .failure(SupabaseAuthService.accountError(from: error))
        }
    }
    
    // Opens the saved session when the app starts (only tried once per launch)
    @MainActor
    func restoreSession() async -> UserAccount? {
        guard !didRestoreSession else { return nil }
        didRestoreSession = true
        guard let profile = await SupabaseAuthService.restoreSession(),
              let account = try? await loadAccount(profile, fallbackEmail: profile.email ?? "") else { return nil }
        currentAccount = account
        return account
    }
    
    // Builds the account (applicant, or employer + company) from the database rows
    @MainActor
    private func loadAccount(_ profile: ProfileRow, fallbackEmail: String) async throws -> UserAccount {
        let email = profile.email ?? fallbackEmail
        if profile.role == "employer" {
            let loaded = try await SupabaseStore.fetchEmployer(id: profile.id, email: email)
            var employer = loaded?.0 ?? Employer()
            employer.id = profile.id
            employer.email = email
            var company = loaded?.1 ?? Company()
            company.id = profile.id.uuidString.lowercased()
            return UserAccount(id: profile.id, role: .employer, email: email, employer: employer, company: company)
        }
        var applicant = try await SupabaseStore.fetchApplicant(id: profile.id, email: email) ?? AplInfoController.blankApplicant()
        applicant.id = profile.id
        applicant.email = email
        return UserAccount(id: profile.id, role: .applicant, email: email, applicant: applicant)
    }
    
    func signOut() {
        currentAccount = nil
        JobBoard.shared.clear()
        Task { try? await SupabaseAuthService.signOut() }
    }
    
    // MARK: - Profile updates
    
    @MainActor
    @discardableResult
    func updateApplicant(_ applicant: Applicant) async -> Bool {
        do {
            try await SupabaseStore.saveApplicant(applicant)
            if var account = currentAccount, account.applicant?.id == applicant.id {
                var profile = applicant
                profile.password = ""
                account.applicant = profile
                currentAccount = account
            }
            return true
        } catch {
            return false
        }
    }
    
    @MainActor
    @discardableResult
    func updateEmployer(_ employer: Employer, company: Company) async -> Bool {
        guard let userID = currentAccount?.id else { return false }
        do {
            try await SupabaseStore.saveEmployer(employer, company: company, userID: userID)
            return true
        } catch {
            return false
        }
    }
}
