//
//  ProductDetailView.swift
//  gourd
//

import SwiftUI

struct ProductDetailView: View {
    let item: PantryDisplayItem

    @State private var quantity: Double = 1.0
    @State private var isConsumed = false
    @Environment(\.dismiss) private var dismiss

    // MARK: - Derived helpers

    private var expiryMessage: String? {
        switch item.badge {
        case .expToday:       return "Expires today"
        case .expDays(let d): return "Expires in \(d) day\(d == 1 ? "" : "s")"
        case .expired:        return "This item has expired"
        case .fresh:          return nil
        }
    }

    private var expiryIsUrgent: Bool {
        switch item.badge {
        case .expToday, .expired: return true
        case .expDays(let d):     return d <= 3
        default:                  return false
        }
    }

    private var storageTip: (icon: String, title: String, body: String) {
        switch item.category {
        case .dairy:
            return ("refrigerator", "Keep refrigerated at 4°C",
                    "Store on the middle shelf. Avoid keeping dairy in the door to maintain consistent temperature.")
        case .produce:
            return ("leaf", "Store in the crisper drawer",
                    "Keep away from ethylene-producing fruits like apples. Maintain humidity for leafy greens.")
        case .staples:
            return ("cabinet", "Store in a cool, dry place",
                    "Keep sealed to maintain freshness. Avoid exposure to moisture and direct sunlight.")
        case .frozen:
            return ("snowflake", "Keep frozen at −18°C",
                    "Seal tightly to prevent freezer burn. Thaw in the refrigerator overnight before use.")
        default:
            return ("shippingbox", "Store properly",
                    "Follow the manufacturer's storage instructions to ensure maximum freshness and safety.")
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.ftWarmBeige.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    heroImage
                    contentBlock
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                }
                .padding(.bottom, 110)
            }

            markAsConsumedButton
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Product Details")
                    .font(.ftBody(17, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.ftDeepForest)
                }
            }
        }
        .toolbarBackground(Color.ftWarmBeige, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Hero Image

    private var heroImage: some View {
        ProductImage(
            urlString: item.imageURL,
            fallbackIcon: item.iconName,
            fallbackBg: item.iconBg,
            cornerRadius: 16
        )
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Content Block

    private var contentBlock: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Name + category badge
            HStack(alignment: .top, spacing: 10) {
                Text(item.name)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundStyle(Color.ftDeepForest)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Text(item.category.rawValue.uppercased())
                    .font(.ftBody(10, weight: .bold))
                    .kerning(0.5)
                    .foregroundStyle(Color.ftOlive)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.ftOlive.opacity(0.12))
                            .overlay(Capsule().strokeBorder(Color.ftOlive.opacity(0.3), lineWidth: 1))
                    )
                    .padding(.top, 4)
            }

            // Expiry banner
            if let msg = expiryMessage {
                HStack(spacing: 8) {
                    Image(systemName: expiryIsUrgent ? "exclamationmark.circle.fill" : "clock.badge.exclamationmark.fill")
                        .font(.system(size: 15))
                    Text(msg)
                        .font(.ftBody(14, weight: .semibold))
                }
                .foregroundStyle(expiryIsUrgent ? Color.ftCrimson : Color.ftBronze)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill((expiryIsUrgent ? Color.ftCrimson : Color.ftBronze).opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder((expiryIsUrgent ? Color.ftCrimson : Color.ftBronze).opacity(0.2), lineWidth: 1)
                        )
                )
            }

            // Current Stock
            sectionLabel("CURRENT STOCK")
            currentStockRow

            // Storage Guidelines
            sectionLabel("STORAGE GUIDELINES")
            storageGuidelinesCard

            // Consumption History
            sectionLabel("CONSUMPTION HISTORY")
            consumptionHistoryCard
        }
    }

    // MARK: - Current Stock

    private var currentStockRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.1f", quantity))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ftDeepForest)
                Text(item.detail)
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest50)
            }

            Spacer()

            HStack(spacing: 16) {
                Button(action: { if quantity > 0.5 { quantity -= 0.5 } }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.ftOlive)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .strokeBorder(Color.ftOlive, lineWidth: 1.5)
                        )
                }

                Text(String(format: "%.0f", quantity * 2 == floor(quantity * 2) ? quantity : quantity))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ftDeepForest)
                    .frame(minWidth: 24)

                Button(action: { quantity += 0.5 }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.ftOlive))
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    // MARK: - Storage Guidelines

    private var storageGuidelinesCard: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.ftOlive.opacity(0.1))
                    .frame(width: 38, height: 38)
                Image(systemName: storageTip.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.ftOlive)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(storageTip.title)
                    .font(.ftBody(14, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                Text(storageTip.body)
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest50)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    // MARK: - Consumption History

    private var consumptionHistoryCard: some View {
        VStack(spacing: 0) {
            historyRow(
                icon: "bag.fill",
                label: "Last Purchased",
                value: "Oct 12, 2025"
            )
            Divider()
                .background(Color.ftSoftClay.opacity(0.5))
                .padding(.leading, 54)
            historyRow(
                icon: "fork.knife",
                label: "Last Consumed",
                value: "Today, 8:45 AM"
            )
        }
        .background(cardBackground)
    }

    private func historyRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.ftSoftClay.opacity(0.4))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.5))
            }

            Text(label)
                .font(.ftBody(14))
                .foregroundStyle(Color.ftDeepForest)

            Spacer()

            Text(value)
                .font(.ftBody(13))
                .foregroundStyle(Color.ftDeepForest50)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
    }

    // MARK: - Mark as Consumed

    private var markAsConsumedButton: some View {
        Button(action: { isConsumed.toggle() }) {
            Text(isConsumed ? "Marked as Consumed ✓" : "Mark as Consumed")
                .font(.ftBody(16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isConsumed ? Color.ftOlive : Color.ftDeepForest)
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isConsumed)
        .ftShadowMd()
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.ftBody(11, weight: .semibold))
            .foregroundStyle(Color.ftDeepForest.opacity(0.4))
            .kerning(1.2)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(item: mockItems[0])
    }
}
