//
//  SubscriptionSuccessScreen.swift
//  gourdo
//

import SwiftUI

struct SubscriptionSuccessScreen: View {
    let onClose: () -> Void

    private let features: [(icon: String, title: String, description: String)] = [
        ("barcode.viewfinder", "Unlimited pantry tracking",    "Add and track as many items as you need."),
        ("bell.badge",         "Smart expiry notifications",   "Get alerted 3 days, 1 day, and same-day before things expire."),
        ("fork.knife",         "AI recipe generation",         "Turn expiring ingredients into meals instantly."),
        ("chart.bar",          "Waste insights",               "See what you're saving and where food goes."),
        ("arrow.clockwise",    "Weekly summaries",             "A roundup of your pantry health every week."),
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            // Subtle glow
            Circle()
                .fill(Color.green600.opacity(0.2))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: 60, y: -180)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.green800.opacity(0.5))
                                    .frame(width: 100, height: 100)
                                Circle()
                                    .stroke(Color.green600.opacity(0.4), lineWidth: 1)
                                    .frame(width: 100, height: 100)
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 44, weight: .light))
                                    .foregroundStyle(Color.green200)
                            }

                            VStack(spacing: 8) {
                                Text("Welcome to gourdo Pro!")
                                    .font(.ftDisplay(28))
                                    .foregroundStyle(Color.textPrimary)
                                    .multilineTextAlignment(.center)

                                Text("Here's what you'll be getting")
                                    .font(.custom("Saira", size: 16))
                                    .foregroundStyle(Color.textSecondary)
                            }
                        }
                        .padding(.top, 56)

                        // Feature list
                        VStack(spacing: 0) {
                            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                                HStack(alignment: .top, spacing: 16) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.green800.opacity(0.5))
                                            .frame(width: 42, height: 42)
                                        Image(systemName: feature.icon)
                                            .font(.system(size: 18))
                                            .foregroundStyle(Color.green200)
                                    }

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(feature.title)
                                            .font(.custom("Saira", size: 15).weight(.semibold))
                                            .foregroundStyle(Color.textPrimary)
                                        Text(feature.description)
                                            .font(.custom("Saira", size: 13))
                                            .foregroundStyle(Color.textSecondary)
                                            .lineSpacing(2)
                                    }

                                    Spacer()
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 20)

                                if index < features.count - 1 {
                                    Divider()
                                        .background(Color.white.opacity(0.07))
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                        .background(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 120)
                }

                // Sticky close button
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.06))

                    Button(action: onClose) {
                        Text("Let's go!")
                            .font(.ftDisplay(17))
                            .foregroundStyle(Color.appBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.green200)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
                .background(Color.appBackground)
            }
        }
    }
}
