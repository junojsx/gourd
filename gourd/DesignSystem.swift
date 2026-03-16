//
//  DesignSystem.swift
//  gourd
//
//  FreshTrack Design System — Color palette & typography helpers.
//

import SwiftUI

// MARK: - Colors

extension Color {
    // Foundational
    static let ftWarmBeige   = Color(hex: "EFE6DD") // Primary background
    static let ftDeepForest  = Color(hex: "2D3A2D") // Primary text

    // Functional
    static let ftOlive       = Color(hex: "4A674D") // Primary action / buttons
    static let ftSoftClay    = Color(hex: "DDBEA9") // Borders, inputs, secondary bg

    // Alerts
    static let ftCrimson     = Color(hex: "7E2224") // Expired / critical
    static let ftBronze      = Color(hex: "94632F") // Use soon / warning

    // Freshness grades
    static let ftFresh       = Color(hex: "22C55E")
    static let ftGood        = Color(hex: "EAB308")
    static let ftUseSoon     = Color(hex: "F97316")
    static let ftUrgent      = Color(hex: "EF4444")
    static let ftExpired     = Color(hex: "6B7280")
    static let ftUnknown     = Color(hex: "9CA3AF")

    // Convenience opacity variants
    static let ftDeepForest70 = Color(hex: "2D3A2D").opacity(0.7)
    static let ftDeepForest50 = Color(hex: "2D3A2D").opacity(0.5)
    static let ftDeepForest40 = Color(hex: "2D3A2D").opacity(0.4)

    /// Placeholder text for inputs — contrast meets WCAG AA (≥4.5:1) on ftWarmBeige and light inputs.
    static let ftPlaceholder = Color(hex: "5A655A")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Typography helpers

extension Font {
    // Display — maps to system serif as Sohne/Freight Big aren't bundled yet
    static func ftDisplay(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    // Body — system sans-serif as Maax placeholder
    static func ftBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Shadow presets

extension View {
    func ftShadowSm() -> some View {
        shadow(color: Color.ftDeepForest.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    func ftShadowMd() -> some View {
        shadow(color: Color.ftDeepForest.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

