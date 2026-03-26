//
//  Screen2HowItWorks.swift
//  gourdo
//
//  Onboarding Screen 2 — How It Works: three feature cards.
//

import SwiftUI

// MARK: - Data

private struct OBFeature {
    let emoji: String
    let title: String
    let desc: String
    let accentColor: Color
}

private let obFeatures: [OBFeature] = [
    OBFeature(
        emoji: "\u{1F4F7}",
        title: "Scan it in seconds",
        desc: "Barcode scan or snap the expiry date — OCR reads it automatically.",
        accentColor: .green600
    ),
    OBFeature(
        emoji: "\u{1F4CA}",
        title: "Track freshness automatically",
        desc: "38 produce types with smart storage windows built in. No manual entry.",
        accentColor: .teal600
    ),
    OBFeature(
        emoji: "\u{1F37D}\u{FE0F}",
        title: "AI recipes from what's expiring",
        desc: "Claude turns your about-to-expire ingredients into tonight's dinner.",
        accentColor: .amber800
    ),
]

// MARK: - Screen

struct Screen2HowItWorks: View {
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 7, current: 1)
                .padding(.top, 20)
                .padding(.bottom, 24)

            (Text("Your pantry, ")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary)
            + Text("always")
                .font(.ftDisplay(28))
                .foregroundColor(.green100)
            + Text(" fresh.")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 6)

            Text("Three things Gourdo does so you don\u{2019}t have to.")
                .font(.ftBody(14))
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

            VStack(spacing: 10) {
                ForEach(obFeatures, id: \.title) { feature in
                    OBFeatureCard(feature: feature)
                }
            }
            .padding(.bottom, 24)

            Spacer()

            OnboardingPrimaryButton(title: "Got it, show me more", action: onNext)
            SkipButton(action: onSkip)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}

// MARK: - Feature Card

private struct OBFeatureCard: View {
    let feature: OBFeature

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(feature.accentColor.opacity(0.35))
                .frame(width: 48, height: 48)
                .overlay(Text(feature.emoji).font(.system(size: 22)))

            VStack(alignment: .leading, spacing: 3) {
                Text(feature.title)
                    .font(.ftBody(13, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Text(feature.desc)
                    .font(.ftBody(11))
                    .foregroundColor(.textMuted)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.surfaceBase)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(16)
    }
}
