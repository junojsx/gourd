//
//  OnboardingDesignTokens.swift
//  gourd
//
//  Color & font tokens used exclusively by the onboarding flow.
//  Font helpers prefixed with "ob" to avoid clashing with SwiftUI's built-in Font.body.
//

import SwiftUI
import UIKit

// MARK: - Onboarding Colors

extension Color {
    // Greens
    static let green50  = Color(hex: "EAF3DE")
    static let green100 = Color(hex: "C0DD97")
    static let green200 = Color(hex: "97C459")
    static let green600 = Color(hex: "3A7D44")
    static let green800 = Color(hex: "1E3F22")
    static let green900 = Color(hex: "0C1F0E")

    // Amber
    static let amber100 = Color(hex: "FAC775")
    static let amber800 = Color(hex: "633806")

    // Teal
    static let teal200  = Color(hex: "5DCAA5")
    static let teal600  = Color(hex: "0F6E56")

    // Urgency
    static let coral200  = Color(hex: "F0997B")
    static let red200    = Color(hex: "F09595")
    static let red400    = Color(hex: "E24B4A")
    static let orange400 = Color(hex: "EF9F27")

    // Surface (dark UI)
    static let appBackground    = Color(hex: "2C2C2A")
    static let surfaceBase      = Color(hex: "1A1A18")
    static let surfaceElevated  = Color.white.opacity(0.07)
    static let surfaceBorder    = Color.white.opacity(0.12)

    // Text
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.55)
    static let textMuted     = Color.white.opacity(0.30)
    static let textDisabled  = Color.white.opacity(0.25)
}

// MARK: - RoundedCorner Shape Helper

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
