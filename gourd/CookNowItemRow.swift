//
//  CookNowItemRow.swift
//  gourd
//
//  Selectable pantry item row used inside CookNowView.
//

import SwiftUI

struct CookNowItemRow: View {
    let item: PantryItem
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            isSelected ? Color.ftOlive : Color.ftSoftClay,
                            lineWidth: 1.5
                        )
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isSelected ? Color.ftOlive : Color.clear)
                        )
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: isSelected)

                // Category icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.category.iconBgColor)
                        .frame(width: 40, height: 40)
                    Image(systemName: item.category.systemImage)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.ftDeepForest.opacity(0.7))
                }

                // Name + quantity
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.ftBody(15, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                        .lineLimit(1)
                    Text(item.quantityDisplay)
                        .font(.ftBody(12))
                        .foregroundStyle(Color.ftDeepForest50)
                }

                Spacer(minLength: 0)

                // Freshness badge + expiry label
                VStack(alignment: .trailing, spacing: 4) {
                    Text(item.freshnessGrade.badgeLabel)
                        .font(.ftBody(9, weight: .bold))
                        .foregroundStyle(item.freshnessGrade.badgeLabelColor)
                        .kerning(0.4)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(item.freshnessGrade.badgeBgColor)
                        )

                    if let days = item.daysUntilExpiry {
                        Text(expiryLabel(days: days))
                            .font(.ftBody(11))
                            .foregroundStyle(Color.ftDeepForest.opacity(0.4))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected
                          ? Color.ftOlive.opacity(0.06)
                          : Color.ftCardBg.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color.ftOlive.opacity(0.35) : Color.ftSoftClay.opacity(0.4),
                                lineWidth: 1
                            )
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    private func expiryLabel(days: Int) -> String {
        switch days {
        case ..<0:  return "Expired"
        case 0:     return "Today"
        case 1:     return "Tomorrow"
        default:    return "In \(days)d"
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        CookNowItemRow(item: .preview, isSelected: false, onToggle: {})
        CookNowItemRow(item: .preview, isSelected: true,  onToggle: {})
    }
    .padding()
    .background(Color.ftWarmBeige)
}
