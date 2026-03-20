//
//  Screen6NotificationsPermission.swift
//  gourd
//
//  Onboarding Screen 6 — Ask for notification permission.
//

import SwiftUI
import UserNotifications

struct Screen6NotificationsPermission: View {
    let onNext: () -> Void

    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 7, current: 5)
                .padding(.top, 20)
                .padding(.bottom, 32)

            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.green800.opacity(0.6))
                    .frame(width: 100, height: 100)
                Circle()
                    .stroke(Color.green600.opacity(0.4), lineWidth: 1)
                    .frame(width: 100, height: 100)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.green100)
            }
            .padding(.bottom, 28)

            // Headline
            (Text("Get nudged before\nthings ")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary)
            + Text("go bad.")
                .font(.ftDisplay(28))
                .foregroundColor(.green100))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 14)

            Text("We\u{2019}ll send a heads-up 3 days out, 1 day out, and the morning of \u{2014} so you always have time to cook something great.")
                .font(.ftBody(14))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)

            Spacer()

            // Mock iOS permission dialog preview
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text("\u{1F331} \u{201C}Gourdo\u{201D} Would Like to\nSend You Notifications")
                        .font(.ftBody(13, weight: .semibold))
                        .foregroundColor(.textPrimary.opacity(0.85))
                        .multilineTextAlignment(.center)
                    Text("Notifications may include alerts, sounds, and icon badges.")
                        .font(.ftBody(11))
                        .foregroundColor(.textMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider()
                    .background(Color.white.opacity(0.1))

                HStack(spacing: 0) {
                    Text("Don\u{2019}t Allow")
                        .font(.ftBody(13))
                        .foregroundColor(.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)

                    Divider()
                        .background(Color.white.opacity(0.1))
                        .frame(height: 36)

                    Text("Allow")
                        .font(.ftBody(13, weight: .semibold))
                        .foregroundColor(.green100)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
            }
            .background(Color.white.opacity(0.07))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12), lineWidth: 0.5))
            .cornerRadius(14)
            .padding(.bottom, 28)

            // Primary CTA
            Button(action: requestPermission) {
                if isRequesting {
                    ProgressView()
                        .tint(.appBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                } else {
                    Text("Enable Notifications")
                        .font(.ftDisplay(17))
                        .foregroundColor(.appBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                }
            }
            .background(Color.green200)
            .cornerRadius(12)
            .disabled(isRequesting)
            .padding(.bottom, 0)

            Button("Not now") { onNext() }
                .font(.ftBody(14))
                .foregroundColor(.textMuted)
                .frame(height: 42)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }

    private func requestPermission() {
        isRequesting = true
        Task {
            try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                isRequesting = false
                onNext()
            }
        }
    }
}
