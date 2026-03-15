//
//  AuthManager.swift
//  gourd
//

import Supabase
import SwiftUI

@Observable
final class AuthManager {

    enum AuthState {
        case loading          // initial — checking for restored session
        case authenticated(Session)
        case unauthenticated
    }

    private(set) var authState: AuthState = .loading
    private(set) var isLoading            = false

    var isAuthenticated: Bool {
        if case .authenticated = authState { return true }
        return false
    }

    var currentSession: Session? {
        if case .authenticated(let s) = authState { return s }
        return nil
    }

    var currentUserEmail: String? {
        currentSession?.user.email
    }

    // MARK: - Init
    // Starts observing auth state changes. The first event (.initialSession)
    // will be emitted immediately with either a restored session or nil.
    init() {
        Task { await observeAuthState() }
    }

    private func observeAuthState() async {
        for await (_, session) in supabase.auth.authStateChanges {
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.authState = session.map { AuthManager.AuthState.authenticated($0) } ?? .unauthenticated
                }
            }
        }
    }

    // MARK: - Sign Up
    // Returns true if email confirmation is required (session is nil)
    @MainActor
    func signUp(email: String, password: String) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }
        let response = try await supabase.auth.signUp(email: email, password: password)
        if let session = response.session {
            authState = .authenticated(session)
            return false
        }
        return true  // email confirmation required
    }

    // MARK: - Sign In
    @MainActor
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        let session = try await supabase.auth.signIn(email: email, password: password)
        authState = .authenticated(session)
    }

    // MARK: - Sign Out
    @MainActor
    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        try await supabase.auth.signOut()
        withAnimation(.easeInOut(duration: 0.25)) {
            authState = .unauthenticated
        }
    }

    // MARK: - Update Password
    @MainActor
    func updatePassword(_ newPassword: String) async throws {
        isLoading = true
        defer { isLoading = false }
        try await supabase.auth.update(user: UserAttributes(password: newPassword))
    }

    // MARK: - Reset Password (sends email)
    @MainActor
    func resetPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        try await supabase.auth.resetPasswordForEmail(email)
    }

    // MARK: - Delete Account
    // Calls a SECURITY DEFINER Postgres function that deletes the auth.users row
    // (cascades to profiles). See claude/004_delete_account_fn.sql.
    @MainActor
    func deleteAccount() async throws {
        isLoading = true
        defer { isLoading = false }
        try await supabase.rpc("delete_account").execute()
        withAnimation(.easeInOut(duration: 0.25)) {
            authState = .unauthenticated
        }
    }
}
