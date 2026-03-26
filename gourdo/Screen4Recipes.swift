//
//  Screen4Recipes.swift
//  gourdo
//
//  Onboarding Screen 4 — AI Recipes: mock recipe card.
//

import SwiftUI

struct Screen4Recipes: View {
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 7, current: 3)
                .padding(.top, 20)
                .padding(.bottom, 20)

            // Mock recipe card — styled per design system card spec
            VStack(alignment: .leading, spacing: 0) {

                // AI badge
                Text("\u{2726} AI-generated \u{00B7} uses expiring items")
                    .font(.ftBody(10, weight: .semibold))
                    .foregroundColor(.green100)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green800)
                    .cornerRadius(6)
                    .padding(.bottom, 10)

                Text("Spinach & Avocado Power Bowl")
                    .font(.ftDisplay(17))
                    .foregroundColor(.textPrimary)
                    .padding(.bottom, 4)

                Text("20 min \u{00B7} Easy \u{00B7} 2 servings")
                    .font(.ftBody(11))
                    .foregroundColor(.textDisabled)
                    .padding(.bottom, 12)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.bottom, 12)

                Text("INGREDIENTS")
                    .font(.ftBody(9, weight: .semibold))
                    .foregroundColor(.textMuted)
                    .kerning(0.5)
                    .padding(.bottom, 8)

                FlowLayout(spacing: 5) {
                    IngredientPill(name: "spinach",         urgency: .urgent)
                    IngredientPill(name: "avocado",         urgency: .soon)
                    IngredientPill(name: "cherry tomatoes", urgency: .soon)
                    IngredientPill(name: "lemon",           urgency: .ok)
                    IngredientPill(name: "olive oil",       urgency: .ok)
                    IngredientPill(name: "garlic",          urgency: .ok)
                }
            }
            .padding(16)
            .background(Color.surfaceBase)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .cornerRadius(16)
            .padding(.bottom, 20)

            (Text("Dinner ideas from ")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary)
            + Text("your")
                .font(.ftDisplay(28))
                .foregroundColor(.green100)
            + Text(" fridge.")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)

            Text("Before anything goes bad, Gourdo suggests recipes built around your expiring ingredients \u{2014} powered by Claude AI.")
                .font(.ftBody(14))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)

            HStack(spacing: 8) {
                MiniStatCard(eyebrow: "Uses expiring items first", label: "Zero waste cooking")
                MiniStatCard(eyebrow: "Instant generation",        label: "Personalized to you")
            }
            .padding(.bottom, 24)

            Spacer()
            OnboardingPrimaryButton(title: "One more thing \u{2192}", action: onNext)
            SkipButton(action: onSkip)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}
