//
//  NotificationPrefs.swift
//  gourd
//
//  Observable, UserDefaults-backed notification preferences.
//  Inject via .environment(NotificationPrefs.shared) or access via .shared.
//

import Foundation
import Observation

@Observable
final class NotificationPrefs {

    static let shared = NotificationPrefs()

    // MARK: - Stored Properties

    /// Master switch — when false, no notifications are scheduled.
    var enabled: Bool {
        didSet { save(); scheduleIfNeeded() }
    }

    /// Fire a notification when items expire the same day.
    var cookNowSameDay: Bool {
        didSet { save(); scheduleIfNeeded() }
    }

    /// Fire a notification when items expire in 1 day.
    var cookNowOneDay: Bool {
        didSet { save(); scheduleIfNeeded() }
    }

    /// Fire a notification when items expire in 3 days.
    var cookNowThreeDay: Bool {
        didSet { save(); scheduleIfNeeded() }
    }

    /// Hour of day (0–23) at which to fire notifications.
    var alertHour: Int {
        didSet { save(); scheduleIfNeeded() }
    }

    /// Minute (0 or 30) at which to fire notifications.
    var alertMinute: Int {
        didSet { save(); scheduleIfNeeded() }
    }

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let enabled         = "notif_enabled"
        static let sameDay         = "notif_same_day"
        static let oneDay          = "notif_one_day"
        static let threeDay        = "notif_three_day"
        static let alertHour       = "notif_alert_hour"
        static let alertMinute     = "notif_alert_minute"
    }

    // MARK: - Init

    private init() {
        let d = UserDefaults.standard
        enabled         = d.object(forKey: Keys.enabled)    as? Bool ?? true
        cookNowSameDay  = d.object(forKey: Keys.sameDay)    as? Bool ?? true
        cookNowOneDay   = d.object(forKey: Keys.oneDay)     as? Bool ?? true
        cookNowThreeDay = d.object(forKey: Keys.threeDay)   as? Bool ?? true
        alertHour       = d.object(forKey: Keys.alertHour)  as? Int  ?? 9
        alertMinute     = d.object(forKey: Keys.alertMinute) as? Int ?? 0
    }

    // MARK: - Persistence

    private func save() {
        let d = UserDefaults.standard
        d.set(enabled,         forKey: Keys.enabled)
        d.set(cookNowSameDay,  forKey: Keys.sameDay)
        d.set(cookNowOneDay,   forKey: Keys.oneDay)
        d.set(cookNowThreeDay, forKey: Keys.threeDay)
        d.set(alertHour,       forKey: Keys.alertHour)
        d.set(alertMinute,     forKey: Keys.alertMinute)
    }

    // MARK: - Reschedule trigger

    /// Kicks the scheduler whenever a preference changes.
    /// Runs on a detached Task so didSet doesn't need to be async.
    private func scheduleIfNeeded() {
        Task { @MainActor in
            let items = PantryRepository.lastKnownItems
            await ExpiryNotificationScheduler.shared.reschedule(items: items, prefs: self)
        }
    }

    // MARK: - Formatted alert time

    var alertTimeDisplay: String {
        let h = alertHour % 12 == 0 ? 12 : alertHour % 12
        let m = String(format: "%02d", alertMinute)
        let period = alertHour < 12 ? "AM" : "PM"
        return "\(h):\(m) \(period)"
    }
}
