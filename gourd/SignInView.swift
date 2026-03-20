//
//  SignInView.swift
//  gourd
//

import SwiftUI

struct SignInView: View {
    @Environment(AuthManager.self) private var auth

    @State private var email            = ""
    @State private var password         = ""
    @State private var showPassword     = false
    @State private var errorMessage     = ""
    @State private var showResetConfirm = false

    private var formIsValid: Bool {
        email.contains("@") && email.contains(".") && !password.isEmpty
    }

    var body: some View {
        ZStack {
            Color.ftWarmBeige.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 64)
                        .padding(.bottom, 40)

                    formSection
                        .padding(.horizontal, 24)

                    signInButton
                        .padding(.horizontal, 24)
                        .padding(.top, 28)

                    forgotPasswordButton
                        .padding(.top, 16)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.ftBody(13))
                            .foregroundStyle(Color.ftCrimson)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if showResetConfirm {
                        Text("Check your email for a reset link")
                            .font(.ftBody(13))
                            .foregroundStyle(Color.ftOlive)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    signUpPrompt
                        .padding(.top, 24)
                        .padding(.bottom, 48)
                }
            }

            // Loading overlay
            if auth.isLoading {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                VStack(spacing: 14) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.3)
                    Text("Signing in...")
                        .font(.ftBody(15, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .transaction { $0.animation = nil }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image("GourdLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 300)

            Text("gourdo")
                .font(.ftDisplay(32))
                .foregroundStyle(Color.ftDeepForest)

            Text("Start saving money and stop wasting food.")
                .font(.ftBody(16))
                .foregroundStyle(Color.ftDeepForest50)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Welcome back")
                .font(.ftBody(20, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest)
                .padding(.bottom, 4)

            FTTextField(
                label: "Email address",
                placeholder: "you@example.com",
                text: $email,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            FTSecureField(
                label: "Password",
                placeholder: "Your password",
                text: $password,
                isVisible: $showPassword
            )
        }
    }

    // MARK: - Sign In Button

    private var signInButton: some View {
        Button(action: {
            errorMessage = ""
            showResetConfirm = false
            guard isValidEmailFormat(email) else {
                errorMessage = "Invalid email, email must be in this format: firstlastname@email.com"
                return
            }
            Task {
                do {
                    try await auth.signIn(email: email, password: password)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Sign In")
                    .font(.ftBody(16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(formIsValid ? Color.ftOlive : Color.ftOlive.opacity(0.4))
            )
        }
        .disabled(!formIsValid)
        .ftShadowSm()
    }

    // MARK: - Forgot Password

    private var forgotPasswordButton: some View {
        Button(action: {
            errorMessage = ""
            showResetConfirm = false
            guard email.contains("@") && email.contains(".") else {
                errorMessage = "Enter your email address first."
                return
            }
            Task {
                do {
                    try await auth.resetPassword(email: email)
                    showResetConfirm = true
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }) {
            Text("Forgot password?")
                .font(.ftBody(14))
                .foregroundStyle(Color.ftDeepForest.opacity(0.6))
                .underline()
        }
    }

    // MARK: - Error Helpers

    private func isValidEmailFormat(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }

    // MARK: - Sign Up Prompt

    private var signUpPrompt: some View {
        HStack(spacing: 4) {
            Text("New here?")
                .font(.ftBody(14))
                .foregroundStyle(Color.ftDeepForest50)
            NavigationLink(destination: SignUpView()) {
                Text("Create Account")
                    .font(.ftBody(14, weight: .semibold))
                    .foregroundStyle(Color.ftOlive)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignInView()
    }
    .environment(AuthManager())
}
