//
//  ProductDetailView.swift
//  gourd
//

import SwiftUI

struct ProductDetailView: View {
    let item: PantryItem

    @State private var quantity: Double
    @State private var isMarkingConsumed = false
    @Environment(PantryRepository.self) private var repo
    @Environment(\.dismiss) private var dismiss

    init(item: PantryItem) {
        self.item = item
        _quantity = State(initialValue: item.quantity)
    }

    // MARK: - Derived helpers

    private var expiryMessage: String? {
        guard let days = item.daysUntilExpiry else { return nil }
        switch days {
        case ..<0: return "This item has expired"
        case 0:    return "Expires today"
        case 1:    return "Expires tomorrow"
        default:   return "Expires in \(days) days"
        }
    }

    private var storageTip: (icon: String, title: String, body: String) {
        switch item.category {
        case .dairy:
            return ("refrigerator", "Keep refrigerated at 4°C",
                    "Store on the middle shelf. Avoid keeping dairy in the door to maintain consistent temperature.")
        case .produce:
            return ("leaf.fill", "Store in the crisper drawer",
                    "Keep away from ethylene-producing fruits like apples. Maintain humidity for leafy greens.")
        case .meat:
            return ("refrigerator", "Keep refrigerated below 4°C",
                    "Store on the bottom shelf to prevent cross-contamination. Use within 1–2 days or freeze.")
        case .frozen:
            return ("snowflake", "Keep frozen at −18°C",
                    "Seal tightly to prevent freezer burn. Thaw in the refrigerator overnight before use.")
        case .bakery:
            return ("cabinet.fill", "Keep in a bread box or sealed bag",
                    "Store at room temperature away from moisture. Freeze sliced bread to extend freshness.")
        case .canned:
            return ("cabinet.fill", "Store in a cool, dry place",
                    "Keep sealed in the original can. Once opened, transfer to a covered container in the fridge.")
        case .beverage:
            return ("refrigerator", "Keep refrigerated after opening",
                    "Store upright to prevent leaks. Consume within the timeframe on the label once opened.")
        case .other:
            return ("shippingbox.fill", "Store properly",
                    "Follow the manufacturer's storage instructions to ensure maximum freshness and safety.")
        }
    }

    private static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    // MARK: - Body

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                heroImage
                contentBlock
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 24)
        }
        .background(Color.ftWarmBeige)
        .safeAreaInset(edge: .bottom) {
            markAsConsumedButton
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 90)
                .background(Color.ftWarmBeige)
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
                Button(action: {
                    Task { try? await repo.deleteItem(item.id) }
                    dismiss()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.ftCrimson)
                }
            }
        }
        .toolbarBackground(Color.ftWarmBeige.opacity(1), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }

    // MARK: - Hero Image

    private var heroImage: some View {
        ProductImage(
            urlString: item.imageUrl ?? "",
            fallbackIcon: item.category.systemImage,
            fallbackBg: item.category.iconBgColor,
            cornerRadius: 16
        )
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Content Block

    private var contentBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Text(item.name)
                    .font(.ftDisplay(20))
                    .foregroundStyle(Color.ftDeepForest)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Text(item.category.displayName.uppercased())
                    .font(.ftBody(11, weight: .semibold))
                    .kerning(0.5)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.ftDeepForest))
                    .padding(.top, 2)
            }

            if let msg = expiryMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 13))
                    Text(msg)
                        .font(.ftBody(13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(item.isUrgent ? Color.ftCrimson : Color.ftBronze))
            }

            sectionLabel("CURRENT STOCK")
            currentStockRow

            sectionLabel("STORAGE GUIDELINES")
            storageGuidelinesCard

            sectionLabel("DETAILS")
            detailsCard
        }
    }

    // MARK: - Current Stock

    private var currentStockRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: quantity == floor(quantity) ? "%.0f" : "%.1f", quantity))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ftDeepForest)
                Text(item.unit)
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
                        .background(Circle().strokeBorder(Color.ftOlive, lineWidth: 1.5))
                }

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

    // MARK: - Details Card

    private var detailsCard: some View {
        VStack(spacing: 0) {
            if let brand = item.brand {
                detailRow(icon: "tag.fill", label: "Brand", value: brand)
                Divider()
                    .background(Color.ftSoftClay.opacity(0.5))
                    .padding(.leading, 54)
            }
            if let purchaseDate = item.purchaseDate {
                detailRow(
                    icon: "bag.fill",
                    label: "Purchased",
                    value: Self.displayDateFormatter.string(from: purchaseDate)
                )
                Divider()
                    .background(Color.ftSoftClay.opacity(0.5))
                    .padding(.leading, 54)
            }
            if let expiryDate = item.expiryDate {
                detailRow(
                    icon: "calendar",
                    label: "Expires",
                    value: Self.displayDateFormatter.string(from: expiryDate)
                )
                Divider()
                    .background(Color.ftSoftClay.opacity(0.5))
                    .padding(.leading, 54)
            }
            detailRow(
                icon: item.storageLocation.systemImage,
                label: "Storage",
                value: item.storageLocation.displayName
            )
        }
        .background(cardBackground)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
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

    private var consumeButtonLabel: String {
        if quantity <= 0.5 {
            return "Use Last & Remove"
        } else {
            return "Use One (\(item.quantityDisplay) left)"
        }
    }

    private var markAsConsumedButton: some View {
        Button(action: {
            guard !isMarkingConsumed else { return }
            isMarkingConsumed = true
            Task {
                if quantity <= 0.5 {
                    // Last bit — mark fully consumed
                    do {
                        try await repo.markConsumed(item.id)
                    } catch {
                        print("❌ markConsumed error:", error)
                        // Refetch to sync state even if update had issues
                        await repo.fetchItems()
                    }
                    dismiss()
                } else {
                    // Decrease by 1, but floor at 0.5
                    quantity = max(0.5, quantity - 1)
                    var updated = item
                    updated.quantity = quantity
                    try? await repo.updateItem(updated)
                    isMarkingConsumed = false
                }
            }
        }) {
            HStack(spacing: 8) {
                if isMarkingConsumed {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: quantity <= 0.5 ? "trash" : "minus.circle")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(isMarkingConsumed ? "Updating..." : consumeButtonLabel)
                    .font(.ftBody(16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(quantity <= 0.5 ? Color.ftCrimson : Color.ftDeepForest)
            )
        }
        .disabled(isMarkingConsumed)
        .animation(.easeInOut(duration: 0.2), value: isMarkingConsumed)
        .animation(.easeInOut(duration: 0.2), value: quantity)
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
            .fill(Color.ftCardBg.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(item: .preview)
            .environment(PantryRepository())
    }
}
