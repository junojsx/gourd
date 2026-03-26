//
//  Screen5Notifications.swift
//  gourdo
//
//  Onboarding Screen 5 — Notifications: timely expiry alerts.
//

import SwiftUI

struct Screen5Notifications: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 7, current: 4)
                .padding(.top, 20)
                .padding(.bottom, 20)

            // Notification examples stack
            VStack(spacing: 8) {
                OBNotificationBanner(
                    timeLabel: "3 days before",
                    badgeColor: .green100,
                    title: "Gourdo",
                    message: "Spinach, avocado & 2 more items expire in 3 days. Got a recipe?"
                )
                OBNotificationBanner(
                    timeLabel: "1 day before",
                    badgeColor: .amber100,
                    title: "Gourdo",
                    message: "Your avocados expire tomorrow. We\u{2019}ve got a 20-min recipe ready."
                )
                OBNotificationBanner(
                    timeLabel: "Same day",
                    badgeColor: .red400,
                    title: "Gourdo",
                    message: "Last chance \u{2014} spinach expires today. Cook Now before it\u{2019}s gone."
                )
            }
            .padding(.bottom, 24)

            (Text("We\u{2019}ll remind you before it\u{2019}s ")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary)
            + Text("too late.")
                .font(.ftDisplay(28))
                .foregroundColor(.green100))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)

            Text("Three timely nudges \u{2014} 3-day, 1-day, and same-day \u{2014} so groceries get used, not binned. Set your preferred alert time once; we handle the rest.")
                .font(.ftBody(14))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
            OnboardingPrimaryButton(title: "See Gourdo Pro \u{2192}", action: onNext)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}

// MARK: - Notification Banner Component

private struct OBNotificationBanner: View {
    let timeLabel: String
    let badgeColor: Color
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Time label
            Text(timeLabel)
                .font(.ftBody(9, weight: .semibold))
                .foregroundColor(badgeColor)
                .frame(width: 70, alignment: .leading)
                .padding(.top, 2)

            // Banner
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green800)
                    .frame(width: 32, height: 32)
                    .overlay(Text("\u{1F331}").font(.system(size: 16)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.ftBody(12, weight: .semibold))
                        .foregroundColor(.textPrimary.opacity(0.9))
                    Text(message)
                        .font(.ftBody(11))
                        .foregroundColor(.textMuted)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(10)
            .background(Color.white.opacity(0.07))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(badgeColor.opacity(0.25), lineWidth: 0.5)
            )
            .cornerRadius(12)
        }
    }
}
