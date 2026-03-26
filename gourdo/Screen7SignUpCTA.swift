//
//  Screen7SignUpCTA.swift
//  gourdo
//
//  Onboarding Screen 7 — Sign-up pitch before the auth screen.
//

import SwiftUI

struct Screen7SignUpCTA: View {
    let onCreateAccount: () -> Void
    let onSignIn: () -> Void

    private let benefits = [
        (icon: "barcode.viewfinder", text: "Scan items in seconds — barcode or expiry date"),
        (icon: "bell.badge",         text: "Alerts 3 days, 1 day, and same-day before expiry"),
        (icon: "fork.knife",         text: "AI recipes built around what\u{2019}s about to go bad"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 7, current: 6)
                .padding(.top, 20)
                .padding(.bottom, 32)

            Spacer()

            // Hero
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.green800.opacity(0.55))
                        .frame(width: 88, height: 88)
                    Circle()
                        .stroke(Color.green600.opacity(0.35), lineWidth: 1)
                        .frame(width: 88, height: 88)
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(.green100)
                }

                Text("You're one step away.")
                    .font(.ftDisplay(28))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Create a free account and put an end to wasted groceries \u{2014} for good.")
                    .font(.ftBody(14))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
            .padding(.bottom, 32)

            // Benefit list
            VStack(spacing: 12) {
                ForEach(benefits, id: \.text) { benefit in
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green800.opacity(0.6))
                                .frame(width: 36, height: 36)
                            Image(systemName: benefit.icon)
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(.green100)
                        }
                        Text(benefit.text)
                            .font(.ftBody(13))
                            .foregroundColor(.textSecondary)
                            .lineSpacing(2)
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color.surfaceBase)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .cornerRadius(16)

            Spacer()

            // CTAs
            OnboardingPrimaryButton(title: "Create free account", action: onCreateAccount)
                .padding(.bottom, 0)

            Button(action: onSignIn) {
                Text("I already have an account")
                    .font(.ftBody(14))
                    .foregroundColor(.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
            }
            .contentShape(Rectangle())
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}
