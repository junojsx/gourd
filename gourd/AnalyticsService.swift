//
//  AnalyticsService.swift
//  gourd
//
//  Thin PostHog wrapper. Add calls at the integration points below —
//  never scatter PostHogSDK.shared.capture() across the codebase directly.
//
//  DEBUG builds set optOut = true in gourdApp, so all events are no-ops
//  during development and won't pollute production data.
//

import Foundation
import PostHog

enum AnalyticsService {

    // MARK: - Pantry

    static func itemAdded(method: AddedVia, category: ItemCategory) {
        capture("item_added", properties: [
            "method": method.rawValue,
            "category": category.rawValue
        ])
    }

    static func itemConsumed(daysUntilExpiry: Int?, category: ItemCategory) {
        capture("item_consumed", properties: [
            "days_until_expiry": daysUntilExpiry as Any,
            "category": category.rawValue
        ])
    }

    static func itemDeleted(reason: String = "other") {
        capture("item_deleted", properties: ["reason": reason])
    }

    static func pantryViewed(itemCount: Int, expiredCount: Int) {
        capture("pantry_viewed", properties: [
            "item_count": itemCount,
            "expired_count": expiredCount
        ])
    }

    // MARK: - Scanning

    static func barcodeScanned(success: Bool) {
        capture("barcode_scanned", properties: ["success": success])
    }

    static func ocrScanned(success: Bool, dateFound: Bool) {
        capture("ocr_scanned", properties: [
            "success": success,
            "date_found": dateFound
        ])
    }

    static func scanLimitHit() {
        capture("scan_limit_hit")
    }

    // MARK: - Recipes

    static func recipeGenerated(ingredientCount: Int, cacheHit: Bool) {
        capture("recipe_generated", properties: [
            "ingredient_count": ingredientCount,
            "cache_hit": cacheHit,
            "model": "claude-haiku-4-5"
        ])
    }

    static func recipeViewed(fromCache: Bool) {
        capture("recipe_viewed", properties: ["from_cache": fromCache])
    }

    static func recipeLimitHit() {
        capture("recipe_limit_hit")
    }

    // MARK: - Subscription / Paywall

    enum PaywallTrigger: String {
        case scanLimit   = "scan_limit"
        case recipeLimit = "recipe_limit"
        case pantryLimit = "pantry_limit"
        case proFeature  = "pro_feature"
    }

    static func paywallShown(trigger: PaywallTrigger) {
        capture("paywall_shown", properties: ["trigger": trigger.rawValue])
    }

    static func subscriptionStarted(productId: String, isTrial: Bool) {
        capture("subscription_started", properties: [
            "product_id": productId,
            "is_trial": isTrial
        ])
    }

    static func subscriptionCancelled() {
        capture("subscription_cancelled")
    }

    // MARK: - Notifications

    static func notificationPermissionGranted() {
        capture("notification_permission_granted")
    }

    static func notificationTapped(type: String) {
        capture("notification_tapped", properties: ["type": type])
    }

    // MARK: - Private

    private static func capture(_ event: String, properties: [String: Any] = [:]) {
        PostHogSDK.shared.capture(event, properties: properties.isEmpty ? nil : properties)
    }
}
