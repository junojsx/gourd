//
//  SubscriptionManager.swift
//  gourdo
//
//  Central observable for all RevenueCat subscription state.
//  Inject into the environment at app root; read anywhere with @Environment(SubscriptionManager.self).
//

import RevenueCat
import SwiftUI

@Observable
final class SubscriptionManager {

    // MARK: - Public State

    /// Most recently fetched CustomerInfo. Nil until the first stream emission.
    private(set) var customerInfo: CustomerInfo?

    /// True while restoring purchases.
    private(set) var isRestoring = false

    /// Non-nil after a failed restore or login sync.
    private(set) var lastError: Error?

    // MARK: - Computed Entitlement

    /// Single source of truth for Pro access throughout the app.
    var isProSubscriber: Bool {
        customerInfo?.entitlements[Entitlement.gourdoPro]?.isActive == true
    }

    /// True while we're still waiting for the first CustomerInfo emission.
    /// Automatically becomes false after a timeout so the app never blocks indefinitely.
    private(set) var isLoadingInitial: Bool = true

    // MARK: - Constants

    enum Entitlement {
        /// Must match the entitlement identifier in your RevenueCat dashboard exactly.
        static let gourdoPro = "gourdo Pro"
    }

    enum ProductID {
        static let monthly = "monthly"
        static let yearly  = "yearly"
    }

    // MARK: - Lifecycle

    /// Call once at app launch (via `.task`) to keep `customerInfo` in sync indefinitely.
    /// Emits the cached value immediately, then updates on every server-side change.
    /// Falls through the loading state after 5 s so the paywall is never blocked forever.
    @MainActor
    func startListening() async {
        // Timeout: if RC hasn't responded in 5 seconds, unblock the UI.
        Task {
            try? await Task.sleep(for: .seconds(5))
            isLoadingInitial = false
        }

        for await info in Purchases.shared.customerInfoStream {
            customerInfo = info
            isLoadingInitial = false
        }
    }

    /// Pre-warm the offerings cache so the RevenueCat paywall loads instantly.
    func prefetchOfferings() {
        Purchases.shared.getOfferings { _, _ in }
    }

    // MARK: - Auth Sync

    /// Call after Supabase signs in to link the RC anonymous ID to the authenticated user.
    /// RevenueCat will merge purchase history from any prior anonymous session.
    @MainActor
    func logIn(userId: String) async {
        lastError = nil
        isLoadingInitial = true
        do {
            let (info, _) = try await Purchases.shared.logIn(userId)
            customerInfo = info
        } catch {
            lastError = error
        }
        isLoadingInitial = false
    }

    /// Call after Supabase signs out to revert to an anonymous RevenueCat user.
    @MainActor
    func logOut() async {
        lastError = nil
        do {
            customerInfo = try await Purchases.shared.logOut()
        } catch {
            lastError = error
        }
    }

    // MARK: - Direct Update

    /// Apply a CustomerInfo received from a PaywallView purchase/restore callback immediately,
    /// without waiting for the next customerInfoStream emission.
    @MainActor
    func update(_ info: CustomerInfo) {
        customerInfo = info
        isLoadingInitial = false
    }

    // MARK: - Restore Purchases

    @MainActor
    func restorePurchases() async {
        isRestoring = true
        lastError = nil
        do {
            customerInfo = try await Purchases.shared.restorePurchases()
        } catch {
            lastError = error
        }
        isRestoring = false
    }
}
