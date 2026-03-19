//
//  Screen2HowItWorks.swift
//  gourd
//
//  Onboarding Screen 2 — How It Works: Scan → Alert → Cook
//

import SwiftUI

struct Screen2HowItWorks: View {
    let onNext: () -> Void
    let onSkip: () -> Void

    private let steps = [
        (emoji: "\u{1F4F7}", title: "Scan barcodes or snap the date",
         desc: "OCR reads expiry dates from packaging automatically",
         bg: Color.green600.opacity(0.3)),
        (emoji: "\u{1F4CA}", title: "We track freshness for you",
         desc: "38 produce types with smart storage windows built in",
         bg: Color.teal600.opacity(0.4)),
        (emoji: "\u{1F37D}\u{FE0F}", title: "AI recipes from what's about to expire",
         desc: "Claude turns your expiring items into tonight's dinner",
         bg: Color.amber800.opacity(0.4)),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 5, current: 1)
                .padding(.top, 20)
                .padding(.bottom, 20)

            // Scan → Alert → Cook icon row
            HStack(spacing: 0) {
                ForEach(Array(zip(["\u{1F4F7}", "\u{1F514}", "\u{1F373}"], ["Scan", "Alert", "Cook"]).enumerated()),
                        id: \.offset) { i, pair in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill([Color.green800.opacity(0.7),
                                   Color.teal600.opacity(0.7),
                                   Color.green600.opacity(0.5)][i])
                            .frame(width: 70, height: 56)
                            .overlay(Text(pair.0).font(.system(size: 28)))
                        Text(pair.1)
                            .font(.ftBody(10))
                            .foregroundColor([Color.green200, Color.teal200, Color.green100][i])
                    }
                    if i < 2 {
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.green600)
                        Spacer()
                    }
                }
            }
            .padding(.bottom, 20)

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

            Text("Three simple steps \u{2014} then your fridge runs itself.")
                .font(.ftBody(14))
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)

            VStack(spacing: 10) {
                ForEach(steps, id: \.title) { step in
                    HStack(alignment: .top, spacing: 12) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(step.bg)
                            .frame(width: 32, height: 32)
                            .overlay(Text(step.emoji).font(.system(size: 14)))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.title)
                                .font(.ftBody(13, weight: .semibold))
                                .foregroundColor(.textPrimary.opacity(0.9))
                            Text(step.desc)
                                .font(.ftBody(11))
                                .foregroundColor(.textMuted)
                        }
                        Spacer()
                    }
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
