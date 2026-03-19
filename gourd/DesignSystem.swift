//
//  DesignSystem.swift
//  gourd
//
//  FreshTrack Design System — Color palette & typography helpers.
//

import SwiftUI
import UIKit

// MARK: - Adaptive Color Helper

private func adaptiveColor(light: String, dark: String) -> Color {
    Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: dark)
            : UIColor(hex: light)
    })
}

private func adaptiveColor(light: String, lightAlpha: CGFloat = 1.0,
                           dark: String, darkAlpha: CGFloat = 1.0) -> Color {
    Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(hex: dark).withAlphaComponent(darkAlpha)
            : UIColor(hex: light).withAlphaComponent(lightAlpha)
    })
}

// MARK: - Colors
//
// Dark mode palette derived from the onboarding design system:
//   Background  → "2C2C2A" (appBackground)
//   Surface     → "1A1A18" (surfaceBase)
//   Accent      → "97C459" (green200)
//   Text        → white / white-55% / white-30%

extension Color {
    // Foundational
    static let ftWarmBeige   = adaptiveColor(light: "EFE6DD", dark: "2C2C2A")
    static let ftDeepForest  = adaptiveColor(light: "2D3A2D", dark: "FFFFFF")

    // Functional
    static let ftOlive       = adaptiveColor(light: "4A674D", dark: "97C459")
    static let ftSoftClay    = adaptiveColor(light: "DDBEA9", dark: "3A3A38")

    // Card / row background
    static let ftCardBg      = adaptiveColor(light: "FFFFFF", dark: "1A1A18")

    // Alerts
    static let ftCrimson     = adaptiveColor(light: "7E2224", dark: "E24B4A")
    static let ftBronze      = adaptiveColor(light: "94632F", dark: "FAC775")

    // Freshness grades
    static let ftFresh       = adaptiveColor(light: "22C55E", dark: "C0DD97")
    static let ftGood        = adaptiveColor(light: "EAB308", dark: "FAC775")
    static let ftUseSoon     = adaptiveColor(light: "F97316", dark: "EF9F27")
    static let ftUrgent      = adaptiveColor(light: "EF4444", dark: "E24B4A")
    static let ftExpired     = adaptiveColor(light: "6B7280", dark: "9CA3AF")
    static let ftUnknown     = adaptiveColor(light: "9CA3AF", dark: "B0B8C4")

    // Convenience opacity variants
    static let ftDeepForest70 = adaptiveColor(light: "2D3A2D", lightAlpha: 0.7,
                                              dark: "FFFFFF", darkAlpha: 0.7)
    static let ftDeepForest50 = adaptiveColor(light: "2D3A2D", lightAlpha: 0.5,
                                              dark: "FFFFFF", darkAlpha: 0.5)
    static let ftDeepForest40 = adaptiveColor(light: "2D3A2D", lightAlpha: 0.4,
                                              dark: "FFFFFF", darkAlpha: 0.4)

    /// Placeholder text — contrast meets WCAG AA on both light and dark backgrounds.
    static let ftPlaceholder = adaptiveColor(light: "5A655A", dark: "8A8A8A")
}

// MARK: - UIColor hex init

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8)  & 0xFF) / 255
        let b = CGFloat( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

// MARK: - Color hex init (kept for any direct usage)

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
    // Display — ZCOOL QingKe HuangYou for headings
    static func ftDisplay(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .custom("ZCOOLQingKeHuangYou-Regular", size: size)
    }

    // Body — Saira (variable font, supports weights 100–900)
    static func ftBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Saira", size: size).weight(weight)
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
