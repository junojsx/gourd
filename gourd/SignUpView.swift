//
//  SignUpView.swift
//  gourd
//

import SwiftUI

// MARK: - SignUpView

struct SignUpView: View {
    @Environment(AuthManager.self) private var auth

    @State private var email           = ""
    @State private var password        = ""
    @State private var confirmPassword = ""

    @State private var showPassword        = false
    @State private var showConfirmPassword = false

    @State private var emailError           = ""
    @State private var passwordError        = ""
    @State private var confirmPasswordError = ""

    @State private var errorMessage        = ""
    @State private var awaitingConfirmation = false

    private var formIsValid: Bool {
        emailError.isEmpty && passwordError.isEmpty && confirmPasswordError.isEmpty
        && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
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

                    signUpButton
                        .padding(.horizontal, 24)
                        .padding(.top, 28)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.ftBody(13))
                            .foregroundStyle(Color.ftCrimson)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    signInPrompt
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
                    Text("Creating account...")
                        .font(.ftBody(15, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .transaction { $0.animation = nil }
        .alert("Check your email", isPresented: $awaitingConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("We sent a confirmation link to \(email). Click it to activate your account.")
        }
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
            Text("Create your account")
                .font(.ftBody(20, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest)
                .padding(.bottom, 4)

            FTTextField(
                label: "Email address",
                placeholder: "you@example.com",
                text: $email,
                keyboardType: .emailAddress,
                autocapitalization: .never,
                errorMessage: emailError
            )
            .onChange(of: email) { _, _ in validateEmail() }

            FTSecureField(
                label: "Password",
                placeholder: "Min. 8 characters",
                text: $password,
                isVisible: $showPassword,
                errorMessage: passwordError
            )
            .onChange(of: password) { _, _ in validatePassword() }

            FTSecureField(
                label: "Confirm password",
                placeholder: "Re-enter your password",
                text: $confirmPassword,
                isVisible: $showConfirmPassword,
                errorMessage: confirmPasswordError
            )
            .onChange(of: confirmPassword) { _, _ in validateConfirmPassword() }
        }
    }

    // MARK: - Sign Up Button

    private var signUpButton: some View {
        Button(action: handleSignUp) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                Text("Create Account")
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

    // MARK: - Sign In Prompt

    private var signInPrompt: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .font(.ftBody(14))
                .foregroundStyle(Color.ftDeepForest50)
            NavigationLink("Sign In", destination: SignInView())
                .font(.ftBody(14, weight: .semibold))
                .foregroundStyle(Color.ftOlive)
        }
    }

    // MARK: - Validation

    private func validateEmail() {
        if email.isEmpty {
            emailError = ""
        } else if !email.contains("@") || !email.contains(".") {
            emailError = "Enter a valid email address."
        } else {
            emailError = ""
        }
    }

    private func validatePassword() {
        if password.isEmpty {
            passwordError = ""
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters."
        } else {
            passwordError = ""
        }
        if !confirmPassword.isEmpty { validateConfirmPassword() }
    }

    private func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            confirmPasswordError = ""
        } else if confirmPassword != password {
            confirmPasswordError = "Passwords do not match."
        } else {
            confirmPasswordError = ""
        }
    }

    private func handleSignUp() {
        validateEmail()
        validatePassword()
        validateConfirmPassword()
        guard formIsValid else { return }
        errorMessage = ""
        Task {
            do {
                let needsConfirmation = try await auth.signUp(email: email, password: password)
                if needsConfirmation {
                    awaitingConfirmation = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - FTTextField

struct FTTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var errorMessage: String = ""

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.ftBody(13, weight: .medium))
                .foregroundStyle(Color.ftDeepForest70)

            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.ftPlaceholder))
                .font(.ftBody(16))
                .foregroundStyle(Color.ftDeepForest)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .focused($isFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.ftSoftClay.opacity(0.25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(borderColor, lineWidth: isFocused ? 2 : 1)
                        )
                )

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.ftBody(12))
                    .foregroundStyle(Color.ftCrimson)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: errorMessage)
    }

    private var borderColor: Color {
        if !errorMessage.isEmpty { return Color.ftCrimson }
        if isFocused { return Color.ftOlive }
        return Color.ftSoftClay
    }
}

// MARK: - FTSecureField

struct FTSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    var errorMessage: String = ""

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.ftBody(13, weight: .medium))
                .foregroundStyle(Color.ftDeepForest70)

            HStack {
                Group {
                    if isVisible {
                        TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.ftPlaceholder))
                    } else {
                        SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.ftPlaceholder))
                    }
                }
                .font(.ftBody(16))
                .foregroundStyle(Color.ftDeepForest)
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.ftDeepForest40)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.ftSoftClay.opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(borderColor, lineWidth: isFocused ? 2 : 1)
                    )
            )

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.ftBody(12))
                    .foregroundStyle(Color.ftCrimson)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: errorMessage)
    }

    private var borderColor: Color {
        if !errorMessage.isEmpty { return Color.ftCrimson }
        if isFocused { return Color.ftOlive }
        return Color.ftSoftClay
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SignUpView()
    }
    .environment(AuthManager())
}
