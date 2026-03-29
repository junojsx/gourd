//
//  ScreenRecipeGuide.swift
//  gourdo
//
//  Tutorial Screen 3 of 3 — Generating and saving an AI recipe.
//

import SwiftUI

struct ScreenRecipeGuide: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 10, current: 8)
                .padding(.top, 20)
                .padding(.bottom, 24)

            Text("HOW TO USE — 3 OF 3")
                .font(.ftBody(10, weight: .semibold))
                .foregroundColor(.textDisabled)
                .kerning(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            Text("Cook before anything expires.")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

            // Mock Cook Now → Recipe flow
            VStack(spacing: 10) {
                // Item selection mock
                VStack(spacing: 6) {
                    ForEach([("🥬", "Spinach", "Expires today"), ("🍗", "Chicken breast", "Expires tomorrow"), ("🥛", "Greek yogurt", "2 days left")], id: \.0) { emoji, name, expiry in
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.green600.opacity(0.3))
                                    .frame(width: 20, height: 20)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.green200)
                            }
                            Text(emoji).font(.system(size: 15))
                            Text(name)
                                .font(.ftBody(12, weight: .medium))
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Text(expiry)
                                .font(.ftBody(10))
                                .foregroundColor(.textMuted)
                        }
                    }
                }
                .padding(12)
                .background(Color.surfaceBase)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                .cornerRadius(12)

                // Generate button mock
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Generate Recipe (3 items)")
                        .font(.ftBody(13, weight: .semibold))
                }
                .foregroundColor(.appBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green200)
                .cornerRadius(11)

                // Generated recipe card mock
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.amber800.opacity(0.25))
                        .frame(width: 48, height: 48)
                        .overlay(Text("🍲").font(.system(size: 24)))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Chicken & Spinach Skillet")
                            .font(.ftBody(13, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        HStack(spacing: 8) {
                            Label("20 min", systemImage: "clock")
                            Label("Easy", systemImage: "chart.bar")
                        }
                        .font(.ftBody(10))
                        .foregroundColor(.textMuted)
                    }
                    Spacer()
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.green200)
                }
                .padding(12)
                .background(Color.surfaceElevated)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green200.opacity(0.3), lineWidth: 1))
                .cornerRadius(12)
            }
            .padding(.bottom, 20)

            // Steps
            VStack(spacing: 12) {
                OBNumberedStep(number: "1", text: "Open Cook Now when items are close to expiring")
                OBNumberedStep(number: "2", text: "Select the ingredients you want to use up")
                OBNumberedStep(number: "3", text: "Generate your AI recipe — then save it to your collection")
            }

            Spacer()
            OnboardingPrimaryButton(title: "Create my account \u{2192}", action: onNext)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}
