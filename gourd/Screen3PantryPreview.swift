//
//  Screen3PantryPreview.swift
//  gourd
//
//  Onboarding Screen 3 — Pantry Preview: color-coded freshness cards.
//  Card spec from design system: ftCardBg bg · ftSoftClay border · radius-lg · space-4 padding
//

import SwiftUI

// MARK: - Data

private struct OBPantryRow {
    let name: String
    let category: String
    let daysText: String
    let badge: String
    let dotColor: Color
    let badgeColor: Color
    let badgeBg: Color
}

private let obPantryItems: [OBPantryRow] = [
    OBPantryRow(name: "Spinach",         category: "Produce", daysText: "Today",   badge: "URGENT",   dotColor: .red400,    badgeColor: .red400,    badgeBg: Color.red400.opacity(0.15)),
    OBPantryRow(name: "Avocado \u{00D7} 2",      category: "Produce", daysText: "2 days",  badge: "USE SOON", dotColor: .orange400, badgeColor: .orange400, badgeBg: Color.orange400.opacity(0.15)),
    OBPantryRow(name: "Cherry Tomatoes", category: "Produce", daysText: "3 days",  badge: "USE SOON", dotColor: .orange400, badgeColor: .orange400, badgeBg: Color.orange400.opacity(0.15)),
    OBPantryRow(name: "Greek Yogurt",    category: "Dairy",   daysText: "8 days",  badge: "GOOD",     dotColor: .amber100,  badgeColor: .amber100,  badgeBg: Color.amber100.opacity(0.15)),
    OBPantryRow(name: "Cheddar",         category: "Dairy",   daysText: "14 days", badge: "FRESH",    dotColor: .green100,  badgeColor: .green100,  badgeBg: Color.green100.opacity(0.15)),
]

// MARK: - Screen

struct Screen3PantryPreview: View {
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 7, current: 2)
                .padding(.top, 20)
                .padding(.bottom, 20)

            Text("YOUR PANTRY")
                .font(.ftBody(11, weight: .semibold))
                .foregroundColor(.textMuted)
                .kerning(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            VStack(spacing: 7) {
                ForEach(obPantryItems, id: \.name) { item in
                    OBPantryItemRow(item: item)
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

            Text("Color-coded urgency so you always know what to use first. No more \u{201C}I didn\u{2019}t know it was going bad\u{201D} surprises.")
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

// MARK: - Row

private struct OBPantryItemRow: View {
    let item: OBPantryRow

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(item.dotColor)
                .frame(width: 8, height: 8)

            Text(item.name)
                .font(.ftBody(13))
                .foregroundColor(.textPrimary.opacity(0.9))

            Spacer()

            // Category chip — ftSoftClay bg per design system
            Text(item.category)
                .font(.ftBody(10))
                .foregroundColor(.textMuted)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.08))
                .cornerRadius(6)

            // Freshness badge — radius-full, Saira 11px
            Text(item.badge)
                .font(.ftBody(10, weight: .semibold))
                .foregroundColor(item.badgeColor)
                .kerning(0.3)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(item.badgeBg)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.surfaceBase)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
