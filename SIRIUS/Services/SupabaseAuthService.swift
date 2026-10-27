//
//  SupabaseAuthService.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/27/26.
//

// Email + password auth on Supabase Auth, plus the role row in `profiles`.

import Foundation
import Supabase

struct ProfileRow: Codable {
    let id: UUID
    let role: String          // "applicant" or "employer"
    let email: String?
}

enum SupabaseAuthService {
    
    private static var auth: AuthClient { SupabaseService.client.auth }
    
    // Creates the auth user and its `profiles` row. If email confirmation is ON in Supabase,
    // there is no session yet and `needsEmailConfirmation` is true.
    static func signUp(email: String, password: String, role: UserRole) async throws -> (userID: UUID, needsEmailConfirmation: Bool) {
        let response = try await auth.signUp(email: email, password: password)
        let userID = response.user.id
        if response.session == nil {
            return (userID, true)
        }
        try await createProfile(userID: userID, email: email, role: role)
        return (userID, false)
    }
    
    static func signIn(email: String, password: String) async throws -> ProfileRow {
        let session = try await auth.signIn(email: email, password: password)
        return try await fetchProfile(userID: session.user.id)
    }
    
    static func signOut() async throws {
        try await auth.signOut()
    }
    
    // The signed-in user's id, or nil when nobody is signed in
    static func currentUserID() async -> UUID? {
        try? await auth.session.user.id
    }
    
    // Restores a saved session on launch; nil when nobody is signed in.
    static func restoreSession() async -> ProfileRow? {
        guard let session = try? await auth.session else { return nil }
        return try? await fetchProfile(userID: session.user.id)
    }
    
    static func createProfile(userID: UUID, email: String, role: UserRole) async throws {
        let row = ProfileRow(id: userID, role: role == .employer ? "employer" : "applicant", email: email)
        try await SupabaseService.client.from("profiles").upsert(row).execute()
    }
    
    static func fetchProfile(userID: UUID) async throws -> ProfileRow {
        try await SupabaseService.client
            .from("profiles")
            .select()
            .eq("id", value: userID)
            .single()
            .execute()
            .value
    }
    
    // Turns a Supabase / network error into a message the app can show
    static func accountError(from error: Error) -> AccountError {
        if error is URLError { return .network }
        let text = error.localizedDescription.lowercased()
        if text.contains("invalid login") || text.contains("invalid credentials") { return .invalidCredentials }
        if text.contains("already registered") || text.contains("already been registered") { return .emailTaken }
        if text.contains("not confirmed") { return .confirmEmail }
        if text.contains("password") && (text.contains("least") || text.contains("weak")) { return .weakPassword }
        if text.contains("offline") || text.contains("internet") || text.contains("network") || text.contains("timed out") {
            return .network
        }
        return .server(error.localizedDescription)
    }
}
