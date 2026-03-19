//
//  ThemeManager.swift
//  gourd
//
//  Manages light/dark mode preference with persistence.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class ThemeManager {
    private static let key = "app_color_scheme"

    var isDarkMode: Bool {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: Self.key) }
    }

    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }

    init() {
        // Default to system light if no preference saved
        if UserDefaults.standard.object(forKey: Self.key) != nil {
            isDarkMode = UserDefaults.standard.bool(forKey: Self.key)
        } else {
            isDarkMode = true
        }
    }
}
