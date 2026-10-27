//
//  UserAccount.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

import Foundation

struct UserAccount: Identifiable, Hashable {
    var id = UUID()
    var role: UserRole
    var username: String
    var salt: String
    var passwordHash: String
    var applicant: Applicant? = nil
    var employer: Employer? = nil
    var company: Company? = nil
    
    static func == (lhs: UserAccount, rhs: UserAccount) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum AuthError: LocalizedError, Equatable {
    case missingUsername
    case invalidUsername
    case missingPassword
    case weakPassword
    case passwordMismatch
    case usernameTaken
    case invalidCredentials
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .missingUsername: return "Please enter a username."
        case .invalidUsername: return "Username must be at least 3 characters with no spaces."
        case .missingPassword: return "Please enter a password."
        case .weakPassword: return "Password must be at least 6 characters."
        case .passwordMismatch: return "Passwords do not match."
        case .usernameTaken: return "That username is already taken."
        case .invalidCredentials: return "Incorrect username or password."
        case .saveFailed: return "Your account could not be saved on this device. Please try again."
        }
    }
}
