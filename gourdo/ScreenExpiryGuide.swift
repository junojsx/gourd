//
//  ScreenExpiryGuide.swift
//  gourdo
//
//  Tutorial Screen 2 of 3 — Setting the expiry date.
//

import SwiftUI

struct ScreenExpiryGuide: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 10, current: 7)
                .padding(.top, 20)
                .padding(.bottom, 24)

            Text("HOW TO USE — 2 OF 3")
                .font(.ftBody(10, weight: .semibold))
                .foregroundColor(.textDisabled)
                .kerning(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            Text("Set the expiry date, then save.")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

            // Two option cards
            VStack(spacing: 10) {
                // Option A — quick default
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.teal600.opacity(0.25))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "bolt.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.teal600))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Quick save")
                            .font(.ftBody(13, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        Text("Default is 7 days — works fine for most items")
                            .font(.ftBody(11))
                            .foregroundColor(.textMuted)
                            .lineSpacing(2)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.teal600.opacity(0.7))
                }
                .padding(14)
                .background(Color.surfaceBase)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
                .cornerRadius(14)

                // Option B — enter real date
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green600.opacity(0.25))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "calendar")
                            .font(.system(size: 18))
                            .foregroundColor(.green200))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Enter the actual date")
                            .font(.ftBody(13, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        Text("Tap the date field and type the date printed on the label")
                            .font(.ftBody(11))
                            .foregroundColor(.textMuted)
                            .lineSpacing(2)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.surfaceBase)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.green200.opacity(0.35), lineWidth: 1))
                .cornerRadius(14)

                // Save button mock
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("Add to Pantry")
                        .font(.ftBody(14, weight: .semibold))
                }
                .foregroundColor(.appBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color.green200)
                .cornerRadius(12)
            }
            .padding(.bottom, 20)

            // Steps
            VStack(spacing: 12) {
                OBNumberedStep(number: "1", text: "After scanning, the expiry defaults to 7 days from today")
                OBNumberedStep(number: "2", text: "For accuracy, tap the date and enter what's on the label")
                OBNumberedStep(number: "3", text: "Tap \"Add to Pantry\" — Gourdo tracks it from here")
            }

            Spacer()
            OnboardingPrimaryButton(title: "Next \u{2192}", action: onNext)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}
