//
//  PaywallScreen.swift
//  gourd
//
//  Hard paywall backed by RevenueCat's remote paywall builder.
//  UI and copy are configured in the RevenueCat dashboard — no code changes needed
//  to update pricing, layout, or copy.
//

import RevenueCat
import RevenueCatUI
import SwiftUI

struct PaywallScreen: View {
    @Environment(SubscriptionManager.self) private var subscriptions
    @State private var offering: Offering?
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ZStack {
                    Color.appBackground.ignoresSafeArea()
                    ProgressView()
                        .tint(Color.green200)
                        .scaleEffect(1.4)
                }
            } else if let offering {
                PaywallView(offering: offering)
                    .onPurchaseCompleted { info in subscriptions.update(info) }
                    .onRestoreCompleted  { info in subscriptions.update(info) }
            } else {
                // Fallback when no paywall template is configured in the RC dashboard yet.
                fallbackPaywall
            }
        }
        .task {
            await loadOffering()
        }
    }

    // MARK: - Fallback

    private var fallbackPaywall: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Text("🌱")
                        .font(.system(size: 64))
                    Text("gourdo **Pro**")
                        .font(.ftDisplay(32))
                        .foregroundStyle(Color.green200)
                }

                VStack(spacing: 16) {
                    featureRow(icon: "barcode.viewfinder",  text: "Unlimited pantry tracking")
                    featureRow(icon: "bell.badge",          text: "Smart expiry notifications")
                    featureRow(icon: "fork.knife",          text: "AI recipe generation")
                }
                .padding(.horizontal, 32)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        Task { await purchase() }
                    } label: {
                        Text("Start 7-Day Free Trial")
                            .font(.ftDisplay(17))
                            .foregroundStyle(Color.appBackground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.green200)
                            .cornerRadius(12)
                    }

                    Button {
                        Task { await restore() }
                    } label: {
                        Text("Restore purchases")
                            .font(.custom("Saira", size: 14))
                            .foregroundStyle(Color.textMuted)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.green200)
                .frame(width: 28)
            Text(text)
                .font(.custom("Saira", size: 16))
                .foregroundStyle(Color.textPrimary)
            Spacer()
        }
    }

    // MARK: - Actions

    private func loadOffering() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            offering = offerings.current
        } catch {
            offering = nil
        }
        isLoading = false
    }

    private func purchase() async {
        guard let pkg = offering?.availablePackages.first else { return }
        if let result = try? await Purchases.shared.purchase(package: pkg) {
            subscriptions.update(result.customerInfo)
        }
    }

    private func restore() async {
        await subscriptions.restorePurchases()
    }
}
