//
//  ScreenScanGuide.swift
//  gourdo
//
//  Tutorial Screen 1 of 3 — Scanning a barcode.
//

import SwiftUI

struct ScreenScanGuide: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 10, current: 6)
                .padding(.top, 20)
                .padding(.bottom, 24)

            Text("HOW TO USE — 1 OF 3")
                .font(.ftBody(10, weight: .semibold))
                .foregroundColor(.textDisabled)
                .kerning(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            Text("Scan any grocery barcode.")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

            // Mock scanner card
            VStack(spacing: 12) {
                // Scanner viewfinder
                ZStack {
                    Color.black.opacity(0.7)
                    // Barcode lines
                    HStack(spacing: 3) {
                        ForEach(Array([3,1,2,1,3,2,1,2,3,1,2,3,1,2,1,3,2,1].enumerated()), id: \.offset) { _, w in
                            Rectangle()
                                .fill(Color.white.opacity(w == 3 ? 0.9 : 0.45))
                                .frame(width: CGFloat(w), height: 56)
                        }
                    }
                    // Scan line
                    Rectangle()
                        .fill(Color.green200.opacity(0.85))
                        .frame(height: 2)
                        .padding(.horizontal, 28)
                    // Corner brackets
                    ScanCorners()
                        .stroke(Color.green200, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .padding(12)
                }
                .frame(height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Product result row
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green600.opacity(0.25))
                        .frame(width: 40, height: 40)
                        .overlay(Text("🥛").font(.system(size: 20)))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Oat Milk — Oatly")
                            .font(.ftBody(13, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        Text("Dairy alternative · 946 ml")
                            .font(.ftBody(11))
                            .foregroundColor(.textMuted)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green200)
                        .font(.system(size: 18))
                }
                .padding(12)
                .background(Color.surfaceElevated)
                .cornerRadius(12)
            }
            .padding(14)
            .background(Color.surfaceBase)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
            .cornerRadius(18)
            .padding(.bottom, 20)

            // Steps
            VStack(spacing: 12) {
                OBNumberedStep(number: "1", text: "Tap the barcode button at the bottom of the home screen")
                OBNumberedStep(number: "2", text: "Point your camera at any food or drink barcode")
                OBNumberedStep(number: "3", text: "Product name, brand, and category load automatically")
            }

            Spacer()
            OnboardingPrimaryButton(title: "Next \u{2192}", action: onNext)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}

// MARK: - Corner Bracket Shape

private struct ScanCorners: Shape {
    private let len: CGFloat = 18
    private let r: CGFloat = 4

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let (l, r2, t, b) = (rect.minX, rect.maxX, rect.minY, rect.maxY)

        // Top-left
        p.move(to: CGPoint(x: l, y: t + len)); p.addLine(to: CGPoint(x: l, y: t + r))
        p.addQuadCurve(to: CGPoint(x: l + r, y: t), control: CGPoint(x: l, y: t))
        p.addLine(to: CGPoint(x: l + len, y: t))

        // Top-right
        p.move(to: CGPoint(x: r2 - len, y: t)); p.addLine(to: CGPoint(x: r2 - r, y: t))
        p.addQuadCurve(to: CGPoint(x: r2, y: t + r), control: CGPoint(x: r2, y: t))
        p.addLine(to: CGPoint(x: r2, y: t + len))

        // Bottom-right
        p.move(to: CGPoint(x: r2, y: b - len)); p.addLine(to: CGPoint(x: r2, y: b - r))
        p.addQuadCurve(to: CGPoint(x: r2 - r, y: b), control: CGPoint(x: r2, y: b))
        p.addLine(to: CGPoint(x: r2 - len, y: b))

        // Bottom-left
        p.move(to: CGPoint(x: l + len, y: b)); p.addLine(to: CGPoint(x: l + r, y: b))
        p.addQuadCurve(to: CGPoint(x: l, y: b - r), control: CGPoint(x: l, y: b))
        p.addLine(to: CGPoint(x: l, y: b - len))

        return p
    }
}
