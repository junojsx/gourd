//
//  SetupView.swift
//  gourd
//

import SwiftUI

// MARK: - SetupView

struct SetupView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ftWarmBeige.ignoresSafeArea()

                VStack(spacing: 0) {
                    navBar

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            profileCard
                            accountSection
                            signOutSection
                            dangerSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 110)
                    }
                }
            }
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.ftOlive)
                        .frame(width: 34, height: 34)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                }
                Text("Settings")
                    .font(.ftBody(19, weight: .bold))
                    .foregroundStyle(Color.ftDeepForest)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.ftWarmBeige)
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        let email = auth.currentUserEmail ?? "—"
        let initials = email.first.map { String($0).uppercased() } ?? "?"

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.ftOlive.opacity(0.12))
                    .frame(width: 56, height: 56)
                Text(initials)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ftOlive)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("My Account")
                    .font(.ftBody(16, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                Text(email)
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest50)
            }

            Spacer()

            Text("FREE")
                .font(.ftBody(10, weight: .bold))
                .kerning(0.5)
                .foregroundStyle(Color.ftBronze)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.ftBronze.opacity(0.1))
                        .overlay(Capsule().strokeBorder(Color.ftBronze.opacity(0.4), lineWidth: 1))
                )
        }
        .padding(16)
        .background(cardBackground)
    }

    // MARK: - Account Section

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("ACCOUNT MANAGEMENT")

            VStack(spacing: 0) {
                NavigationLink(destination: UpdatePasswordView()) {
                    settingsRow(
                        icon: "lock.fill",
                        iconBg: Color.ftOlive,
                        title: "Update Password",
                        subtitle: "Change your account password"
                    )
                }
                .buttonStyle(.plain)

                rowDivider

                NavigationLink(destination: ManageSubscriptionView()) {
                    settingsRow(
                        icon: "crown.fill",
                        iconBg: Color(hex: "94632F"),
                        title: "Manage Subscription",
                        subtitle: "View plan and billing details"
                    )
                }
                .buttonStyle(.plain)
            }
            .background(cardBackground)
        }
    }

    // MARK: - Sign Out Section

    private var signOutSection: some View {
        Button(action: {
            Task { try? await auth.signOut() }
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
                Spacer()
            }
            .font(.ftBody(15, weight: .semibold))
            .foregroundStyle(Color.ftDeepForest)
            .padding(16)
            .background(cardBackground)
        }
    }

    // MARK: - Danger Section

    private var dangerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("DANGER ZONE")

            NavigationLink(destination: DeleteAccountView()) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.ftCrimson.opacity(0.1))
                            .frame(width: 36, height: 36)
                        Image(systemName: "person.crop.circle.badge.minus")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.ftCrimson)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Delete Account")
                            .font(.ftBody(15, weight: .semibold))
                            .foregroundStyle(Color.ftCrimson)
                        Text("Permanently remove your data")
                            .font(.ftBody(13))
                            .foregroundStyle(Color.ftCrimson.opacity(0.6))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.ftCrimson.opacity(0.4))
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.ftCrimson.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.ftCrimson.opacity(0.25), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private func settingsRow(icon: String, iconBg: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconBg.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(iconBg)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.ftBody(15, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                Text(subtitle)
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest50)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.ftDeepForest.opacity(0.25))
        }
        .padding(14)
    }

    private var rowDivider: some View {
        Divider()
            .background(Color.ftSoftClay.opacity(0.5))
            .padding(.leading, 62)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.ftBody(11, weight: .semibold))
            .foregroundStyle(Color.ftDeepForest.opacity(0.4))
            .kerning(1.2)
            .padding(.leading, 4)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
            )
    }
}

// MARK: - UpdatePasswordView

struct UpdatePasswordView: View {
    @Environment(AuthManager.self) private var auth
    @State private var currentPassword = ""
    @State private var newPassword     = ""
    @State private var confirmPassword = ""
    @State private var showCurrent     = false
    @State private var showNew         = false
    @State private var showConfirm     = false
    @State private var isSaved         = false
    @State private var errorMessage    = ""
    @Environment(\.dismiss) private var dismiss

    private var isValid: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 8 &&
        newPassword == confirmPassword
    }

    private var confirmMismatch: Bool {
        !confirmPassword.isEmpty && confirmPassword != newPassword
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Info banner
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.ftOlive)
                    Text("Use at least 8 characters with a mix of letters and numbers.")
                        .font(.ftBody(13))
                        .foregroundStyle(Color.ftDeepForest.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.ftOlive.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.ftOlive.opacity(0.2), lineWidth: 1)
                        )
                )

                // Fields
                VStack(spacing: 16) {
                    secureField(
                        label: "Current Password",
                        text: $currentPassword,
                        isVisible: $showCurrent,
                        placeholder: "Enter current password"
                    )

                    secureField(
                        label: "New Password",
                        text: $newPassword,
                        isVisible: $showNew,
                        placeholder: "At least 8 characters"
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        secureField(
                            label: "Confirm New Password",
                            text: $confirmPassword,
                            isVisible: $showConfirm,
                            placeholder: "Re-enter new password"
                        )
                        if confirmMismatch {
                            Text("Passwords do not match")
                                .font(.ftBody(12))
                                .foregroundStyle(Color.ftCrimson)
                                .padding(.leading, 4)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(Color.ftWarmBeige)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.ftBody(13))
                        .foregroundStyle(Color.ftCrimson)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                Button(action: {
                    Task {
                        do {
                            try await auth.updatePassword(newPassword)
                            withAnimation { isSaved = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }) {
                    Text(isSaved ? "Password Updated ✓" : "Update Password")
                        .font(.ftBody(16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isSaved ? Color.ftOlive : (isValid ? Color.ftDeepForest : Color.ftDeepForest.opacity(0.3)))
                        )
                }
                .disabled(!isValid || isSaved)
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
            .background(Color.ftWarmBeige)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Update Password")
                    .font(.ftBody(17, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
            }
        }
        .toolbarBackground(Color.ftWarmBeige, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func secureField(label: String, text: Binding<String>, isVisible: Binding<Bool>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.ftBody(13, weight: .medium))
                .foregroundStyle(Color.ftDeepForest.opacity(0.6))

            HStack {
                Group {
                    if isVisible.wrappedValue {
                        TextField(placeholder, text: text)
                    } else {
                        SecureField(placeholder, text: text)
                    }
                }
                .font(.ftBody(15))
                .foregroundStyle(Color.ftDeepForest)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

                Button(action: { isVisible.wrappedValue.toggle() }) {
                    Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.ftDeepForest.opacity(0.35))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.ftSoftClay.opacity(0.6), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - ManageSubscriptionView

struct ManageSubscriptionView: View {
    @State private var showUpgradeConfirm = false
    @State private var isUpgraded = false
    @Environment(\.dismiss) private var dismiss

    private let features: [(String, Bool, Bool)] = [
        // (feature, free, pro)
        ("Pantry tracking",         true,  true),
        ("AI recipe generation",    true,  true),
        ("Unlimited saved recipes", false, true),
        ("Expiry notifications",    false, true),
        ("Shopping list sync",      false, true),
        ("Priority support",        false, true),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Current plan banner
                currentPlanBanner

                // Feature comparison
                featureTable

                if !isUpgraded {
                    upgradeBanner
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 110)
        }
        .background(Color.ftWarmBeige)
        .safeAreaInset(edge: .bottom) {
            if !isUpgraded {
                Button(action: { showUpgradeConfirm = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Upgrade to Pro — $4.99/mo")
                            .font(.ftBody(15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "94632F"))
                    )
                    .ftShadowMd()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.ftWarmBeige)
                .confirmationDialog("Upgrade to Gourd Pro?", isPresented: $showUpgradeConfirm, titleVisibility: .visible) {
                    Button("Upgrade — $4.99/mo") { withAnimation { isUpgraded = true } }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("You'll be charged $4.99/month. Cancel anytime.")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Subscription")
                    .font(.ftBody(17, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
            }
        }
        .toolbarBackground(Color.ftWarmBeige, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var currentPlanBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isUpgraded ? Color(hex: "94632F").opacity(0.12) : Color.ftDeepForest.opacity(0.07))
                    .frame(width: 46, height: 46)
                Image(systemName: isUpgraded ? "crown.fill" : "person.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(isUpgraded ? Color(hex: "94632F") : Color.ftDeepForest.opacity(0.5))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(isUpgraded ? "Gourd Pro" : "Free Plan")
                    .font(.ftBody(16, weight: .bold))
                    .foregroundStyle(Color.ftDeepForest)
                Text(isUpgraded ? "All features unlocked" : "Limited features")
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest50)
            }

            Spacer()

            Text(isUpgraded ? "ACTIVE" : "FREE")
                .font(.ftBody(10, weight: .bold))
                .kerning(0.5)
                .foregroundStyle(isUpgraded ? Color(hex: "94632F") : Color.ftDeepForest.opacity(0.4))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(isUpgraded ? Color(hex: "94632F").opacity(0.1) : Color.ftDeepForest.opacity(0.06))
                        .overlay(Capsule().strokeBorder(
                            isUpgraded ? Color(hex: "94632F").opacity(0.35) : Color.ftDeepForest.opacity(0.15),
                            lineWidth: 1
                        ))
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                )
        )
    }

    private var featureTable: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("FEATURE")
                    .font(.ftBody(10, weight: .bold))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.4))
                    .kerning(0.8)
                Spacer()
                Text("FREE")
                    .font(.ftBody(10, weight: .bold))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.4))
                    .kerning(0.8)
                    .frame(width: 44, alignment: .center)
                Text("PRO")
                    .font(.ftBody(10, weight: .bold))
                    .foregroundStyle(Color(hex: "94632F").opacity(0.7))
                    .kerning(0.8)
                    .frame(width: 44, alignment: .center)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            ForEach(Array(features.enumerated()), id: \.offset) { index, row in
                let (name, free, pro) = row
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.ftSoftClay.opacity(0.4))
                    HStack {
                        Text(name)
                            .font(.ftBody(14))
                            .foregroundStyle(Color.ftDeepForest)
                        Spacer()
                        featureCell(available: free)
                            .frame(width: 44)
                        featureCell(available: pro)
                            .frame(width: 44)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                )
        )
    }

    private func featureCell(available: Bool) -> some View {
        Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle")
            .font(.system(size: 18))
            .foregroundStyle(available ? Color.ftOlive : Color.ftDeepForest.opacity(0.18))
    }

    private var upgradeBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: "94632F"))
            VStack(alignment: .leading, spacing: 3) {
                Text("Unlock everything for $4.99/mo")
                    .font(.ftBody(14, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                Text("Cancel anytime. No commitments.")
                    .font(.ftBody(12))
                    .foregroundStyle(Color.ftDeepForest50)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "94632F").opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(hex: "94632F").opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - DeleteAccountView

struct DeleteAccountView: View {
    @Environment(AuthManager.self) private var auth
    @State private var confirmText  = ""
    @State private var showFinal    = false
    @Environment(\.dismiss) private var dismiss

    private let warningItems = [
        ("tray.full.fill",         "All pantry items will be permanently deleted"),
        ("book.closed.fill",       "All saved recipes will be lost"),
        ("person.crop.circle.fill","Your account and profile will be removed"),
        ("arrow.counterclockwise", "This action cannot be undone"),
    ]

    private var confirmIsValid: Bool {
        confirmText.lowercased() == "delete"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Warning header
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.ftCrimson)
                        Text("This is permanent")
                            .font(.ftBody(17, weight: .bold))
                            .foregroundStyle(Color.ftCrimson)
                    }
                    Text("Deleting your account is irreversible. All your data will be wiped from our servers within 30 days.")
                        .font(.ftBody(14))
                        .foregroundStyle(Color.ftDeepForest.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.ftCrimson.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.ftCrimson.opacity(0.25), lineWidth: 1)
                        )
                )

                // What will be deleted
                VStack(alignment: .leading, spacing: 10) {
                    Text("WHAT GETS DELETED")
                        .font(.ftBody(11, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest.opacity(0.4))
                        .kerning(1.2)
                        .padding(.leading, 4)

                    VStack(spacing: 0) {
                        ForEach(Array(warningItems.enumerated()), id: \.offset) { index, row in
                            let (icon, text) = row
                            VStack(spacing: 0) {
                                if index > 0 {
                                    Divider()
                                        .background(Color.ftSoftClay.opacity(0.4))
                                        .padding(.leading, 50)
                                }
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 7)
                                            .fill(Color.ftCrimson.opacity(0.08))
                                            .frame(width: 34, height: 34)
                                        Image(systemName: icon)
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.ftCrimson.opacity(0.7))
                                    }
                                    Text(text)
                                        .font(.ftBody(14))
                                        .foregroundStyle(Color.ftDeepForest)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 13)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                            )
                    )
                }

                // Confirmation input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type **delete** to confirm")
                        .font(.ftBody(14))
                        .foregroundStyle(Color.ftDeepForest.opacity(0.7))

                    TextField("Type \"delete\" here", text: $confirmText)
                        .font(.ftBody(15))
                        .foregroundStyle(Color.ftDeepForest)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            confirmIsValid ? Color.ftCrimson.opacity(0.5) : Color.ftSoftClay.opacity(0.6),
                                            lineWidth: confirmIsValid ? 1.5 : 1
                                        )
                                )
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(Color.ftWarmBeige)
        .safeAreaInset(edge: .bottom) {
            Button(action: { showFinal = true }) {
                Text("Delete My Account")
                    .font(.ftBody(16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(confirmIsValid ? Color.ftCrimson : Color.ftCrimson.opacity(0.3))
                    )
            }
            .disabled(!confirmIsValid)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.ftWarmBeige)
        }
        .confirmationDialog("Are you absolutely sure?", isPresented: $showFinal, titleVisibility: .visible) {
            Button("Yes, delete my account", role: .destructive) {
                Task { try? await auth.deleteAccount() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone. Your account and all data will be permanently deleted.")
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Delete Account")
                    .font(.ftBody(17, weight: .semibold))
                    .foregroundStyle(Color.ftCrimson)
            }
        }
        .toolbarBackground(Color.ftWarmBeige, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    SetupView()
        .environment(AuthManager())
}
