//
//  UserAccount.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation

// The signed-in user. `id` is the Supabase Auth user id; passwords are never kept in the app.
struct UserAccount: Identifiable, Hashable {
    var id: UUID
    var role: UserRole
    var email: String
    var applicant: Applicant? = nil
    var employer: Employer? = nil
    var company: Company? = nil
    
    static func == (lhs: UserAccount, rhs: UserAccount) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum AccountError: LocalizedError, Equatable {
    case missingEmail
    case invalidEmail
    case missingPassword
    case weakPassword
    case passwordMismatch
    case emailTaken
    case invalidCredentials
    case confirmEmail
    case network
    case saveFailed
    case server(String)
    
    var errorDescription: String? {
        switch self {
        case .missingEmail: return "Please enter your email address."
        case .invalidEmail: return "Please enter a valid email address."
        case .missingPassword: return "Please enter a password."
        case .weakPassword: return "Password must be at least 6 characters."
        case .passwordMismatch: return "Passwords do not match."
        case .emailTaken: return "That email is already registered. Try logging in instead."
        case .invalidCredentials: return "Incorrect email or password."
        case .confirmEmail: return "Check your email and confirm your address, then log in."
        case .network: return "Can't reach the server. Check your internet connection and try again."
        case .saveFailed: return "Your account could not be saved. Please try again."
        case .server(let message): return message
        }
    }
}
