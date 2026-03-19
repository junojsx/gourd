//
//  Screen3PantryPreview.swift
//  gourd
//
//  Onboarding Screen 3 — Pantry Preview: color-coded urgency list
//

import SwiftUI

struct Screen3PantryPreview: View {
    let onNext: () -> Void
    let onSkip: () -> Void

    private let items: [(name: String, days: String, dot: Color, label: Color)] = [
        ("Spinach",          "Today",   .red400,    .red200),
        ("Avocado \u{00D7} 2",      "2 days",  .orange400, .amber100),
        ("Cherry Tomatoes",  "3 days",  .orange400, .amber100),
        ("Greek Yogurt",     "8 days",  .green200,  .green200),
        ("Cheddar",          "14 days", .teal600,   .teal200),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 5, current: 2)
                .padding(.top, 20)
                .padding(.bottom, 20)

            Text("YOUR PANTRY")
                .font(.ftBody(11, weight: .semibold))
                .foregroundColor(.textMuted)
                .kerning(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            VStack(spacing: 7) {
                ForEach(items, id: \.name) { item in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(item.dot)
                            .frame(width: 8, height: 8)
                        Text(item.name)
                            .font(.ftBody(13))
                            .foregroundColor(.textPrimary.opacity(0.85))
                        Spacer()
                        Text(item.days)
                            .font(.ftBody(11, weight: .semibold))
                            .foregroundColor(item.label)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.08), lineWidth: 0.5))
                    .cornerRadius(10)
                }
            }
            .padding(.bottom, 20)

            (Text("Know what to cook ")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary)
            + Text("tonight.")
                .font(.ftDisplay(28))
                .foregroundColor(.green100))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)

            Text("Color-coded urgency so you always know what to use first. No more \"I didn't know it was going bad\" surprises.")
                .font(.ftBody(14))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
            OnboardingPrimaryButton(title: "Nice \u{2014} what else?", action: onNext)
            SkipButton(action: onSkip)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}
