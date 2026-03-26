//
//  ExpiryNotificationScheduler.swift
//  gourdo
//
//  Schedules on-device expiry notifications for the Cook Now feature (free tier).
//  Call `reschedule(items:)` after any pantry data change or on app launch.
//

import Foundation
import UIKit
import UserNotifications

// MARK: - Constants

private enum AppLimits {
    /// iOS allows 64 pending local notifications; keep 4 in reserve for other uses.
    static let maxLocalNotifications = 60
    /// Only notify for items expiring within this many days.
    static let notificationWindowDays = 14
    /// Hour of day (24h) at which to fire notifications when no user pref is set.
    static let defaultAlertHour = 9
    /// Minute of hour at which to fire notifications.
    static let defaultAlertMinute = 0
    /// Prefix used to identify and batch-remove expiry notifications.
    static let idPrefix = "expiry-"
}

// MARK: - ExpiryNotificationScheduler

@MainActor
final class ExpiryNotificationScheduler: NSObject {

    static let shared = ExpiryNotificationScheduler()

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
        registerCategories()
    }

    // MARK: - Permission

    /// Requests notification authorisation. Safe to call multiple times — iOS returns
    /// the cached decision after the first prompt.
    func requestAuthorisation() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if !granted {
                print("[Notifications] Permission denied by user.")
            }
        } catch {
            print("[Notifications] Auth request error:", error)
        }
    }

    // MARK: - Category Registration

    /// Registers the COOK_NOW interactive notification category so the system
    /// shows the "Cook Now" action button on the notification.
    private func registerCategories() {
        let cookNowAction = UNNotificationAction(
            identifier: "COOK_NOW_ACTION",
            title: "Cook Now",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: "COOK_NOW",
            actions: [cookNowAction],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }

    // MARK: - Reschedule

    /// Removes all pending expiry notifications and re-schedules them from scratch.
    /// Should be called after every pantry CRUD operation and on app launch.
    func reschedule(items: [PantryItem], prefs: NotificationPrefs? = nil) async {
        let prefs = prefs ?? NotificationPrefs.shared
        // 1. Remove existing expiry notifications
        let pending = await center.pendingNotificationRequests()
        let expiryIds = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(AppLimits.idPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: expiryIds)

        // 2. Bail if master switch is off or permission not granted
        guard prefs.enabled else { return }

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized ||
              settings.authorizationStatus == .provisional else { return }

        // 3. Gather candidates: non-consumed items with expiry within the window
        let today = Calendar.current.startOfDay(for: .now)
        let windowCutoff = Calendar.current.date(byAdding: .day, value: AppLimits.notificationWindowDays, to: today)!

        let candidates = items.filter { item in
            guard !item.isConsumed,
                  let expiry = item.expiryDate else { return false }
            let expiryDay = Calendar.current.startOfDay(for: expiry)
            return expiryDay <= windowCutoff
        }

        // 4. Build requests for each enabled window (priority: same-day > 1-day > 3-day)
        var requests: [UNNotificationRequest] = []

        let windows: [(ExpiryWindow, Bool, [PantryItem])] = [
            (.sameDay,  prefs.cookNowSameDay,  candidates.filter { ($0.daysUntilExpiry ?? Int.max) == 0 }),
            (.oneDay,   prefs.cookNowOneDay,   candidates.filter { ($0.daysUntilExpiry ?? Int.max) == 1 }),
            (.threeDay, prefs.cookNowThreeDay, candidates.filter { ($0.daysUntilExpiry ?? Int.max) == 3 }),
        ]

        for (window, isEnabled, windowItems) in windows where isEnabled && !windowItems.isEmpty {
            guard requests.count < AppLimits.maxLocalNotifications else { break }
            if let request = makeRequest(for: window, items: windowItems, prefs: prefs) {
                requests.append(request)
            }
        }

        // 5. Schedule all requests
        for request in requests {
            do {
                try await center.add(request)
            } catch {
                print("[Notifications] Failed to schedule \(request.identifier):", error)
            }
        }

        print("[Notifications] Scheduled \(requests.count) expiry notification(s).")
    }

    // MARK: - Request Builder

    private func makeRequest(for window: ExpiryWindow, items: [PantryItem], prefs: NotificationPrefs) -> UNNotificationRequest? {
        guard let fire = fireDate(for: window, prefs: prefs) else { return nil }

        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "COOK_NOW"
        content.sound = .default
        content.userInfo = [
            "deepLink": "gourdo://cook-now?window=\(window.rawValue)"
        ]

        switch window {
        case .sameDay:
            content.title = "Last chance!"
            content.body  = itemBody(items: items, suffix: "expire today — tap to find a recipe before they go.")
        case .oneDay:
            content.title = "Expiring tomorrow!"
            content.body  = itemBody(items: items, suffix: "expire tomorrow. Time to Cook Now?")
        case .threeDay:
            content.title = "Items expiring soon"
            content.body  = itemBody(items: items, suffix: "expire in 3 days. Tap to cook something with them!")
        case .all:
            return nil  // "all" is not a schedulable window
        }

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let id = "\(AppLimits.idPrefix)\(window.rawValue)"
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }

    /// Builds a compact body string: "Spinach, Milk and 2 more expire today…"
    private func itemBody(items: [PantryItem], suffix: String) -> String {
        let names = items.map(\.name)
        switch names.count {
        case 1:
            return "\(names[0]) \(suffix)"
        case 2:
            return "\(names[0]) and \(names[1]) \(suffix)"
        default:
            let preview = names.prefix(2).joined(separator: ", ")
            let extra = names.count - 2
            return "\(preview) and \(extra) more \(suffix)"
        }
    }

    /// Returns the trigger for this window's notification.
    /// Fires at the user's configured alert time today (since we already filtered items by current
    /// daysUntilExpiry). If today's alert time has already passed, fires in 5 seconds so items
    /// added or updated late in the day still trigger a prompt.
    private func fireDate(for window: ExpiryWindow, prefs: NotificationPrefs) -> Date? {
        guard window != .all else { return nil }
        var comps = DateComponents()
        comps.hour   = prefs.alertHour
        comps.minute = prefs.alertMinute
        comps.second = 0

        let today = Calendar.current.startOfDay(for: .now)
        let todayComps = Calendar.current.dateComponents([.year, .month, .day], from: today)
        comps.year  = todayComps.year
        comps.month = todayComps.month
        comps.day   = todayComps.day

        let scheduled = Calendar.current.date(from: comps) ?? Date()
        // If today's alert time has passed, return a near-future date so the notification
        // still fires (e.g. item was just added after 9 AM on its expiry day).
        return scheduled > Date() ? scheduled : Date(timeIntervalSinceNow: 5)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension ExpiryNotificationScheduler: UNUserNotificationCenterDelegate {

    /// Allows notifications to appear as banners even when the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    /// Handles taps on the notification or the "Cook Now" action button.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let deepLink = userInfo["deepLink"] as? String,
           let url = URL(string: deepLink) {
            // Route through the standard URL open path so gourdApp.handleDeepLink picks it up.
            Task { @MainActor in
                await UIApplication.shared.open(url)
            }
        }
        completionHandler()
    }
}
