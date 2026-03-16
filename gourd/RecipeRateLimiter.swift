//
//  RecipeRateLimiter.swift
//  gourd
//
//  Monthly hard cap for AI recipe generation during testing.
//  200 calls ≈ $0.40 at claude-haiku-4-5 pricing, well under $10/month.
//  Resets automatically on the 1st of each calendar month.
//

import Foundation

struct RecipeRateLimiter {

    // MARK: - Limits

    /// Hard safety ceiling during testing. 200 calls ≈ $0.40 at claude-haiku-4-5 pricing.
    static let maxPerMonth = 200

    // MARK: - Keys

    private static let defaults      = UserDefaults.standard
    private static let monthCountKey = "recipe_gen_month_count"
    private static let monthStartKey = "recipe_gen_month_start"

    // MARK: - Public API

    static var remaining: Int {
        resetIfNeeded()
        return max(0, maxPerMonth - defaults.integer(forKey: monthCountKey))
    }

    static var canGenerate: Bool { remaining > 0 }

    /// Call this after a successful generation.
    static func recordGeneration() {
        resetIfNeeded()
        defaults.set(defaults.integer(forKey: monthCountKey) + 1, forKey: monthCountKey)
    }

    /// True if the monthly hard cap has been hit.
    static var monthlyCapReached: Bool {
        resetIfNeeded()
        return defaults.integer(forKey: monthCountKey) >= maxPerMonth
    }

    /// Approximate spend this month based on Haiku pricing.
    /// Input: $0.80/M tokens (~300 tokens/call). Output: $4.00/M tokens (~400 tokens/call).
    static var estimatedMonthlyCost: Double {
        let calls = Double(defaults.integer(forKey: monthCountKey))
        let inputCost  = calls * 300 / 1_000_000 * 0.80
        let outputCost = calls * 400 / 1_000_000 * 4.00
        return inputCost + outputCost
    }

    // MARK: - Private

    private static var currentMonthStart: Date {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        return Calendar.current.date(from: comps) ?? Date()
    }

    private static func resetIfNeeded() {
        let thisMonth   = currentMonthStart
        let storedMonth = defaults.object(forKey: monthStartKey) as? Date
        if storedMonth == nil || storedMonth! < thisMonth {
            defaults.set(0, forKey: monthCountKey)
            defaults.set(thisMonth, forKey: monthStartKey)
        }
    }
}
