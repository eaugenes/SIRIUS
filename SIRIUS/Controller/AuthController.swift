//
//  AuthController.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation
import Combine
import CryptoKit

final class AuthController: ObservableObject {
    
    static let shared = AuthController()
    
    @Published private(set) var accounts: [UserAccount] = []
    @Published private(set) var currentAccount: UserAccount?
    
    init() {}
    
    // All saved applicant profiles (used to match new jobs against applicants)
    var applicantProfiles: [Applicant] {
        accounts.compactMap { $0.role == .applicant ? $0.applicant : nil }
    }
    
    // MARK: - Validation
    
    static let minimumPasswordLength = 6
    
    func validateCredentials(username: String, password: String, confirm: String) -> AuthError? {
        let name = username.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty { return .missingUsername }
        if name.count < 3 || name.contains(" ") { return .invalidUsername }
        if password.isEmpty { return .missingPassword }
        if password.count < Self.minimumPasswordLength { return .weakPassword }
        if password != confirm { return .passwordMismatch }
        if isUsernameTaken(name) { return .usernameTaken }
        return nil
    }
    
    func isUsernameTaken(_ username: String) -> Bool {
        let key = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return accounts.contains { $0.username.lowercased() == key }
    }
    
    // MARK: - Sign up
    
    func registerApplicant(_ applicant: Applicant, password: String, confirm: String) -> Result<UserAccount, AuthError> {
        if let error = validateCredentials(username: applicant.username, password: password, confirm: confirm) {
            return .failure(error)
        }
        var profile = applicant
        profile.username = applicant.username.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.password = ""                           // never stored
        return add(UserAccount(role: .applicant, username: profile.username, salt: "", passwordHash: "", applicant: profile), password: password)
    }
    
    func registerEmployer(_ employer: Employer, company: Company, confirm: String) -> Result<UserAccount, AuthError> {
        if let error = validateCredentials(username: employer.username, password: employer.password, confirm: confirm) {
            return .failure(error)
        }
        var profile = employer
        profile.username = employer.username.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = employer.password
        profile.password = ""                           // never stored
        return add(UserAccount(role: .employer, username: profile.username, salt: "", passwordHash: "", employer: profile, company: company), password: password)
    }
    
    private func add(_ draft: UserAccount, password: String) -> Result<UserAccount, AuthError> {
        var account = draft
        account.salt = UUID().uuidString
        account.passwordHash = Self.hash(password: password, salt: account.salt)
        accounts.append(account)
        guard persist() else {
            accounts.removeAll { $0.id == account.id }
            return .failure(.saveFailed)
        }
        currentAccount = account
        return .success(account)
    }
    
    // MARK: - Log in / out
    
    func login(username: String, password: String) -> Result<UserAccount, AuthError> {
        let key = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if key.isEmpty { return .failure(.missingUsername) }
        if password.isEmpty { return .failure(.missingPassword) }
        
        guard let account = accounts.first(where: { $0.username.lowercased() == key }),
              Self.hash(password: password, salt: account.salt) == account.passwordHash else {
            return .failure(.invalidCredentials)       // same message for unknown user and wrong password
        }
        currentAccount = account
        return .success(account)
    }
    
    func signOut() {
        currentAccount = nil
    }
    
    // MARK: - Profile updates
    
    @discardableResult
    func updateApplicant(_ applicant: Applicant) -> Bool {
        guard let index = accounts.firstIndex(where: { $0.applicant?.id == applicant.id }) else { return false }
        var profile = applicant
        profile.password = ""
        accounts[index].applicant = profile
        if currentAccount?.id == accounts[index].id { currentAccount = accounts[index] }
        return persist()
    }
    
    @discardableResult
    func updateEmployer(_ employer: Employer, company: Company) -> Bool {
        guard let index = accounts.firstIndex(where: { $0.employer?.id == employer.id }) else { return false }
        var profile = employer
        profile.password = ""
        accounts[index].employer = profile
        accounts[index].company = company
        if currentAccount?.id == accounts[index].id { currentAccount = accounts[index] }
        return persist()
    }
    
    // MARK: - Helpers
    
    // TODO(Supabase): write the account to the database; return false on failure.
    private func persist() -> Bool {
        true
    }
    
    static func hash(password: String, salt: String) -> String {
        let digest = SHA256.hash(data: Data((salt + password).utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
