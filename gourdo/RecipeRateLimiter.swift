//
//  RecipeRateLimiter.swift
//  gourdo
//
//  Free tier:  2 recipes per week  (resets each Monday).
//  Pro tier:  50 recipes per month (resets on the 1st).
//

import Foundation

struct RecipeRateLimiter {

    // MARK: - Limits

    static let freeWeeklyLimit  = 2
    static let proMonthlyLimit  = 50

    // MARK: - Keys

    private static let defaults = UserDefaults.standard

    // Weekly (free)
    private static let weekCountKey = "recipe_gen_week_count"
    private static let weekStartKey = "recipe_gen_week_start"

    // Monthly (pro)
    private static let monthCountKey = "recipe_gen_month_count"
    private static let monthStartKey = "recipe_gen_month_start"

    // MARK: - Public API

    static func remaining(isPro: Bool) -> Int {
        if isPro {
            resetMonthlyIfNeeded()
            return max(0, proMonthlyLimit - defaults.integer(forKey: monthCountKey))
        } else {
            resetWeeklyIfNeeded()
            return max(0, freeWeeklyLimit - defaults.integer(forKey: weekCountKey))
        }
    }

    static func canGenerate(isPro: Bool) -> Bool {
        remaining(isPro: isPro) > 0
    }

    static func limit(isPro: Bool) -> Int {
        isPro ? proMonthlyLimit : freeWeeklyLimit
    }

    /// Call this after a successful generation.
    static func recordGeneration(isPro: Bool) {
        if isPro {
            resetMonthlyIfNeeded()
            defaults.set(defaults.integer(forKey: monthCountKey) + 1, forKey: monthCountKey)
        } else {
            resetWeeklyIfNeeded()
            defaults.set(defaults.integer(forKey: weekCountKey) + 1, forKey: weekCountKey)
        }
    }

    // MARK: - Private

    private static var currentWeekStart: Date {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return cal.date(from: comps) ?? Date()
    }

    private static func resetWeeklyIfNeeded() {
        let thisWeek   = currentWeekStart
        let storedWeek = defaults.object(forKey: weekStartKey) as? Date
        if storedWeek == nil || storedWeek! < thisWeek {
            defaults.set(0, forKey: weekCountKey)
            defaults.set(thisWeek, forKey: weekStartKey)
        }
    }

    private static var currentMonthStart: Date {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        return Calendar.current.date(from: comps) ?? Date()
    }

    private static func resetMonthlyIfNeeded() {
        let thisMonth   = currentMonthStart
        let storedMonth = defaults.object(forKey: monthStartKey) as? Date
        if storedMonth == nil || storedMonth! < thisMonth {
            defaults.set(0, forKey: monthCountKey)
            defaults.set(thisMonth, forKey: monthStartKey)
        }
    }
}
