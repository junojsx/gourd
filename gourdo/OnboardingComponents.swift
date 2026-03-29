//
//  OnboardingComponents.swift
//  gourdo
//
//  Shared UI components for the onboarding flow.
//

import SwiftUI

// MARK: - ProgressDots

struct ProgressDots: View {
    let total: Int
    let current: Int  // 0-indexed

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                RoundedRectangle(cornerRadius: 3)
                    .fill(dotColor(for: i))
                    .frame(width: i == current ? 20 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.25), value: current)
            }
        }
    }

    private func dotColor(for index: Int) -> Color {
        if index < current  { return .white.opacity(0.5) }
        if index == current { return .green100 }
        return .white.opacity(0.2)
    }
}

// MARK: - PrimaryButton (Onboarding)
// Spec: ftOlive bg · ftWarmBeige text · ZCOOL 17px · 54px height · radius-md (12px)

struct OnboardingPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.ftDisplay(17))
                .foregroundColor(.appBackground)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.green200)
                .cornerRadius(12)
        }
    }
}

// MARK: - SkipButton
// Spec: transparent · ftPlaceholder text · Saira 14px · 42px height

struct SkipButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Skip")
                .font(.ftBody(14))
                .foregroundColor(.textMuted)
                .frame(height: 42)
        }
    }
}

// MARK: - StatChip

struct StatChip: View {
    let number: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.ftDisplay(24))
                .foregroundColor(.green100)
            Text(label)
                .font(.ftBody(10))
                .foregroundColor(.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.surfaceElevated)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.surfaceBorder, lineWidth: 0.5))
        .cornerRadius(12)
    }
}

// MARK: - IngredientPill

enum PillUrgency { case urgent, soon, ok }

struct IngredientPill: View {
    let name: String
    let urgency: PillUrgency

    private var colors: (bg: Color, border: Color, text: Color) {
        switch urgency {
        case .urgent: return (.coral200.opacity(0.15), .coral200.opacity(0.4), .coral200)
        case .soon:   return (.amber100.opacity(0.12), .amber100.opacity(0.35), .amber100)
        case .ok:     return (.green100.opacity(0.12), .green100.opacity(0.30), .green100)
        }
    }

    var body: some View {
        Text(name)
            .font(.ftBody(10))
            .foregroundColor(colors.text)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(colors.bg)
            .overlay(Capsule().stroke(colors.border, lineWidth: 0.5))
            .clipShape(Capsule())
    }
}

// MARK: - MiniStatCard

struct MiniStatCard: View {
    let eyebrow: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(eyebrow)
                .font(.ftBody(10))
                .foregroundColor(.textDisabled)
            Text(label)
                .font(.ftBody(12, weight: .medium))
                .foregroundColor(.textPrimary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.surfaceElevated)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.surfaceBorder, lineWidth: 0.5))
        .cornerRadius(12)
    }
}

// MARK: - FlowLayout (iOS 16+)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width,
                                subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize,
                       subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: frame.minX + bounds.minX, y: frame.minY + bounds.minY),
                proposal: .unspecified
            )
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth, x > 0 {
                    x = 0; y += rowHeight + spacing; rowHeight = 0
                }
                frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - OBNumberedStep

struct OBNumberedStep: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.ftBody(11, weight: .bold))
                .foregroundColor(.green100)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.green600.opacity(0.3)))
                .overlay(Circle().stroke(Color.green600.opacity(0.4), lineWidth: 0.5))
            Text(text)
                .font(.ftBody(13))
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}

// MARK: - ProFeatureRow

struct ProFeatureRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.green600.opacity(0.4))
                    .frame(width: 16, height: 16)
                Circle()
                    .stroke(Color.green600, lineWidth: 0.5)
                    .frame(width: 16, height: 16)
                Text("\u{2713}")
                    .font(.ftBody(9))
                    .foregroundColor(.green100)
            }
            Text(text)
                .font(.ftBody(12))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
        }
    }
}

// MARK: - PlanCard

struct PlanCard: View {
    let label: String
    let price: String
    let per: String
    let footnote: String
    let footnoteColor: Color
    let trialBadge: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                if let badge = trialBadge {
                    Text(badge)
                        .font(.ftBody(9, weight: .semibold))
                        .foregroundColor(.amber800)
                        .kerning(0.3)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.amber100)
                        .cornerRadius(20)
                        .padding(.bottom, 8)
                } else {
                    Spacer().frame(height: 24)
                }

                Text(label)
                    .font(.ftBody(11))
                    .foregroundColor(isSelected ? .green100 : .white.opacity(0.45))
                    .padding(.bottom, 5)

                Text(price)
                    .font(.ftDisplay(22))
                    .foregroundColor(.textPrimary)

                Text(per)
                    .font(.ftBody(10))
                    .foregroundColor(isSelected ? .green100.opacity(0.6) : .white.opacity(0.35))
                    .padding(.top, 2)

                Text(footnote)
                    .font(.ftBody(10))
                    .foregroundColor(footnoteColor)
                    .padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.green200.opacity(0.1) : Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color.green200 : Color.white.opacity(0.12),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            )
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}
