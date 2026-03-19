//
//  PaywallScreen.swift
//  gourd
//
//  Onboarding Paywall — Plan selection + purchase CTA.
//  RevenueCat purchase logic is stubbed; wire up when SDK is integrated.
//

import SwiftUI

enum PlanSelection { case annual, monthly }

struct PaywallScreen: View {
    let onComplete: () -> Void

    @State private var selectedPlan: PlanSelection = .annual
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ProgressDots(total: 5, current: 5)
                    .padding(.top, 14)
                    .padding(.bottom, 12)

                // Green header band
                VStack(spacing: 6) {
                    Text("GOURDO PRO")
                        .font(.ftBody(10, weight: .semibold))
                        .foregroundColor(.green100)
                        .kerning(1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green100.opacity(0.15))
                        .overlay(Capsule().stroke(Color.green100.opacity(0.3), lineWidth: 0.5))
                        .clipShape(Capsule())

                    Text("Start your \(Text("free trial").foregroundColor(.green100))")
                        .font(.ftDisplay(26))
                        .foregroundColor(.textPrimary)

                    Text("Annual plan only \u{00B7} cancel anytime \u{00B7} no charge for 7 days")
                        .font(.ftBody(12))
                        .foregroundColor(.textMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .padding(.horizontal, 24)
                .background(Color.green800)
                .cornerRadius(20, corners: [.topLeft, .topRight])

                // Main body
                VStack(spacing: 0) {
                    // Plan cards
                    HStack(alignment: .top, spacing: 8) {
                        PlanCard(
                            label: "Annual",
                            price: "$59.99",
                            per: "/ year",
                            footnote: "$5.00 / mo \u{00B7} save 37%",
                            footnoteColor: .green100.opacity(0.7),
                            trialBadge: "7-DAY FREE TRIAL",
                            isSelected: selectedPlan == .annual
                        ) { selectedPlan = .annual }

                        PlanCard(
                            label: "Monthly",
                            price: "$7.99",
                            per: "/ month",
                            footnote: "no free trial",
                            footnoteColor: .white.opacity(0.2),
                            trialBadge: nil,
                            isSelected: selectedPlan == .monthly
                        ) { selectedPlan = .monthly }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    // Trial callout — annual only
                    if selectedPlan == .annual {
                        HStack {
                            Text("\u{2726} 7 days free, then $59.99 / year")
                                .font(.ftBody(11, weight: .semibold))
                                .foregroundColor(.green100)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                                .background(Color.green100.opacity(0.15))
                                .overlay(Capsule().stroke(Color.green100.opacity(0.3), lineWidth: 0.5))
                                .clipShape(Capsule())
                        }
                        .padding(.bottom, 12)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // Pro features
                    VStack(spacing: 6) {
                        ProFeatureRow(text: "Unlimited scans (barcode & OCR)")
                        ProFeatureRow(text: "Unlimited AI recipe generation")
                        ProFeatureRow(text: "Unlimited pantry items")
                        ProFeatureRow(text: "Same-day alerts & weekly summaries")
                        ProFeatureRow(text: "Smart recipe suggestions via notification")

                        Divider()
                            .background(Color.white.opacity(0.08))
                            .padding(.vertical, 4)

                        // Free tier footnote
                        HStack(alignment: .center, spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                                    .frame(width: 16, height: 16)
                                Text("\u{2013}")
                                    .font(.ftBody(9))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            Text("Free: 15 scans \u{00B7} 3 recipes \u{00B7} 20 items / mo")
                                .font(.ftBody(12))
                                .foregroundColor(.white.opacity(0.38))
                            Spacer()
                        }
                    }
                    .padding(.bottom, 14)

                    // Error
                    if let error = errorMessage {
                        Text(error)
                            .font(.ftBody(12))
                            .foregroundColor(.red200)
                            .padding(.bottom, 8)
                    }

                    // Primary CTA
                    Button(action: handlePurchase) {
                        if isPurchasing {
                            ProgressView()
                                .tint(.green900)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        } else {
                            Text(selectedPlan == .annual
                                 ? "Start free trial"
                                 : "Subscribe \u{2014} $7.99 / month")
                                .font(.ftBody(14, weight: .semibold))
                                .foregroundColor(.green900)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                    }
                    .background(Color.green200)
                    .cornerRadius(14)
                    .disabled(isPurchasing)
                    .padding(.bottom, 6)

                    // Ghost CTA
                    Button("Continue with free plan") { onComplete() }
                        .font(.ftBody(12))
                        .foregroundColor(.textDisabled)
                        .padding(.vertical, 8)

                    // Legal
                    Text(legalText)
                        .font(.ftBody(10))
                        .foregroundColor(.white.opacity(0.2))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
                .background(Color.surfaceBase)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedPlan)
    }

    private var legalText: String {
        selectedPlan == .annual
            ? "By continuing you agree to our Terms. Subscription auto-renews unless cancelled 24h before renewal. Manage in App Store settings."
            : "By continuing you agree to our Terms. Subscription auto-renews monthly unless cancelled 24h before renewal. Manage in App Store settings."
    }

    private func handlePurchase() {
        isPurchasing = true
        errorMessage = nil

        // TODO: Wire up RevenueCat purchase flow
        // For now, simulate a brief delay then complete onboarding
        Task {
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run {
                isPurchasing = false
                onComplete()
            }
        }
    }
}
