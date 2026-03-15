//
//  RecipeRateLimiter.swift
//  gourd
//
//  Client-side weekly rate limit for AI recipe generation.
//  Stored in UserDefaults — resets automatically each calendar week.
//

import Foundation

struct RecipeRateLimiter {

    static let maxPerWeek = 5

    private static let defaults     = UserDefaults.standard
    private static let countKey     = "recipe_gen_count"
    private static let weekStartKey = "recipe_gen_week_start"

    // MARK: - Public API

    static var remaining: Int {
        resetIfNeeded()
        return max(0, maxPerWeek - defaults.integer(forKey: countKey))
    }

    static var canGenerate: Bool { remaining > 0 }

    /// Call this after a successful generation.
    static func recordGeneration() {
        resetIfNeeded()
        defaults.set(defaults.integer(forKey: countKey) + 1, forKey: countKey)
    }

    /// Date when the limit resets (start of next week).
    static var resetsOn: Date {
        let weekStart = currentWeekStart
        return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: weekStart) ?? weekStart
    }

    // MARK: - Private

    private static var currentWeekStart: Date {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return cal.date(from: comps) ?? Date()
    }

    private static func resetIfNeeded() {
        let thisWeek = currentWeekStart
        let storedWeek = defaults.object(forKey: weekStartKey) as? Date

        if storedWeek == nil || storedWeek! < thisWeek {
            defaults.set(0, forKey: countKey)
            defaults.set(thisWeek, forKey: weekStartKey)
        }
    }
}
