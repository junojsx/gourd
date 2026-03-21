//
//  SetupView.swift
//  gourd
//

import RevenueCat
import SwiftUI
import UserNotifications

// MARK: - SetupView

struct SetupView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(ThemeManager.self) private var themeManager

    @State private var prefs = NotificationPrefs.shared
    @State private var systemAuthStatus: UNAuthorizationStatus = .notDetermined
    @State private var showTimePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ftWarmBeige.ignoresSafeArea()

                VStack(spacing: 0) {
                    navBar

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            profileCard
                            appearanceSection
                            accountSection
                            notificationsSection
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
        .task { await refreshAuthStatus() }
        .sheet(isPresented: $showTimePicker) {
            AlertTimePicker(hour: $prefs.alertHour, minute: $prefs.alertMinute)
                .presentationDetents([.height(320)])
        }
    }

    private func refreshAuthStatus() async {
        systemAuthStatus = await UNUserNotificationCenter.current()
            .notificationSettings().authorizationStatus
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

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        @Bindable var theme = themeManager
        return VStack(alignment: .leading, spacing: 10) {
            sectionLabel("APPEARANCE")

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.ftOlive.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: theme.isDarkMode ? "moon.fill" : "sun.max.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.ftOlive)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Dark Mode")
                        .font(.ftBody(15, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                    Text(theme.isDarkMode ? "On" : "Off")
                        .font(.ftBody(13))
                        .foregroundStyle(Color.ftDeepForest50)
                }

                Spacer()

                Toggle("", isOn: $theme.isDarkMode)
                    .labelsHidden()
                    .tint(Color.ftOlive)
            }
            .padding(14)
            .background(cardBackground)
        }
    }

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

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("EXPIRY NOTIFICATIONS")

            VStack(spacing: 0) {

                // Master toggle
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.ftOlive.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.ftOlive)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cook Now Alerts")
                            .font(.ftBody(15, weight: .semibold))
                            .foregroundStyle(Color.ftDeepForest)
                        Text(systemAuthStatus == .denied
                             ? "Blocked in Settings — tap to enable"
                             : "Notify when items are about to expire")
                            .font(.ftBody(13))
                            .foregroundStyle(systemAuthStatus == .denied
                                             ? Color.ftCrimson.opacity(0.7)
                                             : Color.ftDeepForest50)
                    }
                    Spacer()
                    if systemAuthStatus == .denied {
                        Button("Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.ftBody(13, weight: .semibold))
                        .foregroundStyle(Color.ftOlive)
                    } else {
                        Toggle("", isOn: $prefs.enabled)
                            .labelsHidden()
                            .tint(Color.ftOlive)
                    }
                }
                .padding(14)

                if prefs.enabled && systemAuthStatus != .denied {

                    rowDivider

                    // Alert time row
                    Button(action: { showTimePicker = true }) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.ftDeepForest.opacity(0.07))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.ftDeepForest.opacity(0.6))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Alert Time")
                                    .font(.ftBody(15, weight: .semibold))
                                    .foregroundStyle(Color.ftDeepForest)
                                Text("Daily notification time")
                                    .font(.ftBody(13))
                                    .foregroundStyle(Color.ftDeepForest50)
                            }
                            Spacer()
                            Text(prefs.alertTimeDisplay)
                                .font(.ftBody(14, weight: .semibold))
                                .foregroundStyle(Color.ftOlive)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.ftDeepForest.opacity(0.25))
                        }
                        .padding(14)
                    }
                    .buttonStyle(.plain)

                    rowDivider

                    // Window toggles header
                    HStack {
                        Text("NOTIFY ME WHEN ITEMS EXPIRE IN")
                            .font(.ftBody(10, weight: .semibold))
                            .foregroundStyle(Color.ftDeepForest.opacity(0.4))
                            .kerning(0.6)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    .padding(.bottom, 4)

                    windowToggleRow(
                        title: "Same Day",
                        subtitle: "Expires today",
                        icon: "flame.fill",
                        iconColor: Color.ftCrimson,
                        isOn: $prefs.cookNowSameDay
                    )

                    rowDivider

                    windowToggleRow(
                        title: "1 Day Before",
                        subtitle: "Expires tomorrow",
                        icon: "exclamationmark.circle.fill",
                        iconColor: Color.ftBronze,
                        isOn: $prefs.cookNowOneDay
                    )

                    rowDivider

                    windowToggleRow(
                        title: "3 Days Before",
                        subtitle: "Expires in 3 days",
                        icon: "calendar.badge.clock",
                        iconColor: Color.ftOlive,
                        isOn: $prefs.cookNowThreeDay
                    )
                }
            }
            .background(cardBackground)
        }
    }

    private func windowToggleRow(
        title: String,
        subtitle: String,
        icon: String,
        iconColor: Color,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(iconColor)
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
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.ftOlive)
        }
        .padding(14)
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
            .fill(Color.ftCardBg.opacity(0.7))
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
                    SecureFormField(
                        label: "Current Password",
                        text: $currentPassword,
                        isVisible: $showCurrent,
                        placeholder: "Enter current password"
                    )

                    SecureFormField(
                        label: "New Password",
                        text: $newPassword,
                        isVisible: $showNew,
                        placeholder: "At least 8 characters"
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        SecureFormField(
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
                        .foregroundStyle(isSaved ? .white : Color.ftWarmBeige)
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

}

// MARK: - SecureFormField

private struct SecureFormField: View {
    let label: String
    @Binding var text: String
    @Binding var isVisible: Bool
    let placeholder: String

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.ftBody(13, weight: .medium))
                .foregroundStyle(Color.ftDeepForest.opacity(0.6))

            HStack {
                Group {
                    if isVisible {
                        TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.ftPlaceholder))
                    } else {
                        SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.ftPlaceholder))
                    }
                }
                .font(.ftBody(15))
                .foregroundStyle(Color.ftDeepForest)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isFocused)

                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.ftDeepForest.opacity(0.35))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.ftCardBg.opacity(0.8))
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
    @Environment(SubscriptionManager.self) private var subscriptions
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var offering: Offering?
    @State private var selectedPackage: Package?
    @State private var isPurchasing = false
    @State private var purchaseError: String?

    private var isPro: Bool { subscriptions.isProSubscriber }

    private var activeEntitlement: EntitlementInfo? {
        let entitlement = subscriptions.customerInfo?.entitlements[SubscriptionManager.Entitlement.gourdoPro]
        return entitlement?.isActive == true ? entitlement : nil
    }

    private let features: [(String, Bool, Bool)] = [
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
                currentPlanBanner

                if isPro {
                    subscriptionDetails
                }

                featureTable

                if !isPro {
                    if let offering {
                        packagePicker(offering: offering)
                    }
                    upgradeBanner
                }

                if isPro {
                    manageButtons
                }

                if let purchaseError {
                    Text(purchaseError)
                        .font(.ftBody(13))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, isPro ? 20 : 110)
        }
        .background(Color.ftWarmBeige)
        .safeAreaInset(edge: .bottom) {
            if !isPro {
                Button(action: { Task { await purchase() } }) {
                    HStack(spacing: 8) {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Text(upgradeButtonLabel)
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
                .disabled(isPurchasing || selectedPackage == nil)
                .opacity(isPurchasing ? 0.7 : 1)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 90)
                .background(Color.ftWarmBeige)
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
        .task { await loadOfferings() }
    }

    // MARK: - Upgrade Button Label

    private var upgradeButtonLabel: String {
        guard let pkg = selectedPackage else {
            return "Upgrade to Pro"
        }
        let price = pkg.storeProduct.localizedPriceString
        let period = pkg.packageType == .annual ? "/yr" : "/mo"
        return "Upgrade to Pro — \(price)\(period)"
    }

    // MARK: - Current Plan Banner

    private var currentPlanBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isPro ? Color(hex: "94632F").opacity(0.12) : Color.ftDeepForest.opacity(0.07))
                    .frame(width: 46, height: 46)
                Image(systemName: isPro ? "crown.fill" : "person.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(isPro ? Color(hex: "94632F") : Color.ftDeepForest.opacity(0.5))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(isPro ? "Gourdo Pro" : "Free Plan")
                    .font(.ftBody(16, weight: .bold))
                    .foregroundStyle(Color.ftDeepForest)
                Text(isPro ? "All features unlocked" : "Limited features")
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest50)
            }

            Spacer()

            Text(statusLabel)
                .font(.ftBody(10, weight: .bold))
                .kerning(0.5)
                .foregroundStyle(isPro ? Color(hex: "94632F") : Color.ftDeepForest.opacity(0.4))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(isPro ? Color(hex: "94632F").opacity(0.1) : Color.ftDeepForest.opacity(0.06))
                        .overlay(Capsule().strokeBorder(
                            isPro ? Color(hex: "94632F").opacity(0.35) : Color.ftDeepForest.opacity(0.15),
                            lineWidth: 1
                        ))
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ftCardBg.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                )
        )
    }

    private var statusLabel: String {
        guard let entitlement = activeEntitlement, entitlement.isActive else { return "FREE" }
        if entitlement.periodType == .trial { return "TRIAL" }
        return "ACTIVE"
    }

    // MARK: - Subscription Details (Pro users)

    private var subscriptionDetails: some View {
        VStack(spacing: 0) {
            if let entitlement = activeEntitlement {
                detailRow(
                    label: "Plan",
                    value: entitlement.productIdentifier == SubscriptionManager.ProductID.yearly
                        ? "Yearly" : "Monthly"
                )

                if entitlement.periodType == .trial {
                    Divider().background(Color.ftSoftClay.opacity(0.4))
                    detailRow(label: "Status", value: "Free Trial")
                }

                if let expirationDate = entitlement.expirationDate {
                    Divider().background(Color.ftSoftClay.opacity(0.4))
                    let willRenew = entitlement.willRenew
                    detailRow(
                        label: willRenew ? "Renews" : "Expires",
                        value: expirationDate.formatted(date: .abbreviated, time: .omitted)
                    )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ftCardBg.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                )
        )
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.ftBody(14))
                .foregroundStyle(Color.ftDeepForest50)
            Spacer()
            Text(value)
                .font(.ftBody(14, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
    }

    // MARK: - Feature Table

    private var featureTable: some View {
        VStack(spacing: 0) {
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

            ForEach(Array(features.enumerated()), id: \.offset) { _, row in
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
                .fill(Color.ftCardBg.opacity(0.7))
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

    // MARK: - Package Picker (Free users)

    private func packagePicker(offering: Offering) -> some View {
        VStack(spacing: 10) {
            ForEach(offering.availablePackages, id: \.identifier) { pkg in
                let isSelected = selectedPackage?.identifier == pkg.identifier
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedPackage = pkg
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundStyle(isSelected ? Color(hex: "94632F") : Color.ftDeepForest.opacity(0.25))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(packageTitle(pkg))
                                .font(.ftBody(15, weight: .semibold))
                                .foregroundStyle(Color.ftDeepForest)
                            if let subtitle = packageSubtitle(pkg) {
                                Text(subtitle)
                                    .font(.ftBody(12))
                                    .foregroundStyle(Color.ftDeepForest50)
                            }
                        }

                        Spacer()

                        Text(pkg.storeProduct.localizedPriceString)
                            .font(.ftBody(15, weight: .bold))
                            .foregroundStyle(Color.ftDeepForest)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.ftCardBg.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        isSelected ? Color(hex: "94632F") : Color.ftSoftClay.opacity(0.4),
                                        lineWidth: isSelected ? 2 : 1
                                    )
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func packageTitle(_ pkg: Package) -> String {
        switch pkg.packageType {
        case .monthly:  return "Monthly"
        case .annual:   return "Yearly"
        default:        return pkg.storeProduct.localizedTitle
        }
    }

    private func packageSubtitle(_ pkg: Package) -> String? {
        switch pkg.packageType {
        case .monthly:  return "Billed monthly"
        case .annual:   return "Billed annually"
        default:        return nil
        }
    }

    // MARK: - Upgrade Banner

    private var upgradeBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: "94632F"))
            VStack(alignment: .leading, spacing: 3) {
                Text("Unlock all features")
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

    // MARK: - Manage Buttons (Pro users)

    private var manageButtons: some View {
        VStack(spacing: 10) {
            if let managementURL = subscriptions.customerInfo?.managementURL {
                Button {
                    openURL(managementURL)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Manage on App Store")
                            .font(.ftBody(15, weight: .semibold))
                    }
                    .foregroundStyle(Color(hex: "94632F"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "94632F").opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color(hex: "94632F").opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }

            Button {
                Task { await subscriptions.restorePurchases() }
            } label: {
                Text("Restore Purchases")
                    .font(.ftBody(14))
                    .foregroundStyle(Color.ftDeepForest50)
            }
            .disabled(subscriptions.isRestoring)
        }
    }

    // MARK: - Actions

    private func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            offering = offerings.current
            // Pre-select monthly by default, fall back to first available
            if let monthly = offering?.monthly {
                selectedPackage = monthly
            } else {
                selectedPackage = offering?.availablePackages.first
            }
        } catch {
            offering = nil
        }
    }

    private func purchase() async {
        guard let pkg = selectedPackage else { return }
        isPurchasing = true
        purchaseError = nil
        do {
            let result = try await Purchases.shared.purchase(package: pkg)
            if !result.userCancelled {
                subscriptions.update(result.customerInfo)
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        isPurchasing = false
    }
}

// MARK: - DeleteAccountView

struct DeleteAccountView: View {
    @Environment(AuthManager.self) private var auth
    @State private var confirmText  = ""
    @State private var showFinal    = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isConfirmFocused: Bool

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
                            .fill(Color.ftCardBg.opacity(0.7))
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

                    TextField("", text: $confirmText, prompt: Text("Type \"delete\" here").foregroundStyle(Color.ftPlaceholder))
                        .font(.ftBody(15))
                        .foregroundStyle(Color.ftDeepForest)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isConfirmFocused)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.ftCardBg.opacity(0.8))
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
            VStack(spacing: 8) {
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.ftBody(13))
                        .foregroundStyle(Color.ftCrimson)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

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
                .disabled(!confirmIsValid || auth.isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.ftWarmBeige)
        }
        .confirmationDialog("Are you absolutely sure?", isPresented: $showFinal, titleVisibility: .visible) {
            Button("Yes, delete my account", role: .destructive) {
                Task {
                    do {
                        try await auth.deleteAccount()
                    } catch {
                        errorMessage = "Failed to delete account. Please try again."
                    }
                }
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
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - AlertTimePicker

struct AlertTimePicker: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Environment(\.dismiss) private var dismiss

    // Generate hour options 6 AM – 10 PM
    private let hours = Array(6...22)
    private let minutes = [0, 15, 30, 45]

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.ftSoftClay)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)

            Text("Alert Time")
                .font(.ftBody(17, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest)
                .padding(.bottom, 20)

            HStack(spacing: 0) {
                // Hour picker
                Picker("Hour", selection: $hour) {
                    ForEach(hours, id: \.self) { h in
                        let label = h > 12 ? "\(h - 12) PM" : (h == 12 ? "12 PM" : "\(h) AM")
                        Text(label).tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                // Minute picker
                Picker("Minute", selection: $minute) {
                    ForEach(minutes, id: \.self) { m in
                        Text(String(format: ":%02d", m)).tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 90)
            }
            .padding(.horizontal, 16)

            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.ftBody(16, weight: .semibold))
                    .foregroundStyle(Color.ftWarmBeige)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.ftDeepForest))
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color.ftWarmBeige.ignoresSafeArea())
    }
}

#Preview {
    SetupView()
        .environment(AuthManager())
}
