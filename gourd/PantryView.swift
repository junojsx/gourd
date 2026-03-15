//
//  PantryView.swift
//  gourd
//

import SwiftUI

// MARK: - Display Models

struct PantryDisplayItem: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let iconName: String
    let iconBg: Color
    let badge: PantryBadge
    let category: PantryCategory
    let imageURL: String
}

enum PantryBadge {
    case fresh
    case expToday
    case expDays(Int)
    case expired

    var label: String {
        switch self {
        case .fresh:         return "FRESH"
        case .expToday:      return "EXP. TODAY"
        case .expDays(let d): return "EXP. \(d) DAYS"
        case .expired:       return "EXPIRED"
        }
    }

    var bgColor: Color {
        switch self {
        case .fresh:    return Color.ftDeepForest.opacity(0.07)
        case .expToday: return Color.ftCrimson.opacity(0.12)
        case .expDays:  return Color.ftBronze.opacity(0.12)
        case .expired:  return Color.ftCrimson.opacity(0.15)
        }
    }

    var labelColor: Color {
        switch self {
        case .fresh:    return Color.ftDeepForest.opacity(0.45)
        case .expToday: return Color.ftCrimson
        case .expDays:  return Color.ftBronze
        case .expired:  return Color.ftCrimson
        }
    }
}

enum PantryCategory: String, CaseIterable {
    case all     = "All Items"
    case dairy   = "Dairy"
    case produce = "Produce"
    case staples = "Staples"
    case frozen  = "Frozen"
    case other   = "Other"
}

// MARK: - Mock Data

let mockItems: [PantryDisplayItem] = [
    // Dairy
    PantryDisplayItem(name: "Whole Milk",       detail: "0.5 Gallon",   iconName: "drop.fill",          iconBg: Color(hex: "E8D5C4"), badge: .expToday,   category: .dairy,   imageURL: "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&q=80&auto=format&fit=crop"),
    PantryDisplayItem(name: "Greek Yogurt",     detail: "2 packs left", iconName: "cup.and.saucer.fill", iconBg: Color(hex: "D4E8D4"), badge: .fresh,      category: .dairy,   imageURL: "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&q=80&auto=format&fit=crop"),
    PantryDisplayItem(name: "Cheddar Cheese",   detail: "200g block",   iconName: "square.fill",        iconBg: Color(hex: "F5E6C8"), badge: .expDays(5), category: .dairy,   imageURL: "https://images.unsplash.com/photo-1618164436241-4473940d1f5c?w=400&q=80&auto=format&fit=crop"),
    PantryDisplayItem(name: "Butter",           detail: "1 stick",      iconName: "rectangle.fill",     iconBg: Color(hex: "FFF3CD"), badge: .fresh,      category: .dairy,   imageURL: "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=400&q=80&auto=format&fit=crop"),

    // Produce
    PantryDisplayItem(name: "Valencia Oranges", detail: "6 units",      iconName: "circle.fill",        iconBg: Color(hex: "FFE0B2"), badge: .expDays(3), category: .produce, imageURL: "https://images.unsplash.com/photo-1547514701-42782101795e?w=400&q=80&auto=format&fit=crop"),
    PantryDisplayItem(name: "Baby Spinach",     detail: "1 bag (5oz)",  iconName: "leaf.fill",          iconBg: Color(hex: "C8E6C9"), badge: .fresh,      category: .produce, imageURL: "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&q=80&auto=format&fit=crop"),
    PantryDisplayItem(name: "Roma Tomatoes",    detail: "4 pieces",     iconName: "circle.fill",        iconBg: Color(hex: "FFCDD2"), badge: .expDays(2), category: .produce, imageURL: "https://images.unsplash.com/photo-1558818373-aaa4b434e69c?w=400&q=80&auto=format&fit=crop"),
    PantryDisplayItem(name: "Broccoli",         detail: "1 head",       iconName: "leaf.fill",          iconBg: Color(hex: "DCEDC8"), badge: .fresh,      category: .produce, imageURL: "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=400&q=80&auto=format&fit=crop"),

    // Staples
    PantryDisplayItem(name: "Jasmine Rice",     detail: "5 lbs bag",    iconName: "cylinder.fill",      iconBg: Color(hex: "F5F0E8"), badge: .fresh,      category: .staples, imageURL: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&q=80&auto=format&fit=crop"),
    PantryDisplayItem(name: "Olive Oil",        detail: "750ml bottle", iconName: "drop.triangle.fill", iconBg: Color(hex: "FFF9C4"), badge: .fresh,      category: .staples, imageURL: "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&q=80&auto=format&fit=crop"),
    PantryDisplayItem(name: "Pasta",            detail: "500g box",     iconName: "lines.measurement.horizontal", iconBg: Color(hex: "F3E5AB"), badge: .fresh, category: .staples, imageURL: "https://images.unsplash.com/photo-1551462147-37885acc36f1?w=400&q=80&auto=format&fit=crop"),
]

// MARK: - PantryView

struct PantryView: View {
    @State private var searchText      = ""
    @State private var selectedCategory: PantryCategory = .all
    @State private var showScanner     = false

    private var filteredItems: [PantryDisplayItem] {
        var items = mockItems
        if selectedCategory != .all {
            items = items.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return items
    }

    private var groupedItems: [(PantryCategory, [PantryDisplayItem])] {
        let categories: [PantryCategory] = selectedCategory == .all
            ? [.dairy, .produce, .staples, .frozen, .other]
            : [selectedCategory]

        return categories.compactMap { cat in
            let items = filteredItems.filter { $0.category == cat }
            return items.isEmpty ? nil : (cat, items)
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                navBar

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        searchBar
                            .padding(.horizontal, 16)
                            .padding(.top, 14)

                        categoryFilters
                            .padding(.top, 12)

                        if groupedItems.isEmpty {
                            emptyState
                        } else {
                            ForEach(groupedItems, id: \.0) { category, items in
                                sectionView(category: category, items: items)
                                    .padding(.top, 24)
                            }
                        }
                    }
                    .padding(.bottom, 110)
                }
            }
            .background(Color.ftWarmBeige.ignoresSafeArea())

            // Scan FAB
            Button(action: { showScanner = true }) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(Circle().fill(Color.ftDeepForest))
                    .ftShadowMd()
            }
            .padding(.trailing, 20)
            .padding(.bottom, 98)
        }
        .sheet(isPresented: $showScanner) {
            ScanProductView()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.ftOlive)
                        .frame(width: 34, height: 34)
                    Image(systemName: "refrigerator")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                }
                Text("Pantry Inventory")
                    .font(.ftBody(19, weight: .bold))
                    .foregroundStyle(Color.ftDeepForest)
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.ftDeepForest)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.ftWarmBeige)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundStyle(Color.ftDeepForest.opacity(0.35))
            TextField("Search items in your pantry...", text: $searchText)
                .font(.ftBody(15))
                .foregroundStyle(Color.ftDeepForest)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.ftDeepForest.opacity(0.3))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ftSoftClay.opacity(0.5), lineWidth: 1)
                )
        )
        .ftShadowSm()
    }

    // MARK: - Category Filters

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PantryCategory.allCases, id: \.self) { cat in
                    filterChip(cat)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    private func filterChip(_ category: PantryCategory) -> some View {
        let isSelected = selectedCategory == category
        return Button(action: { selectedCategory = category }) {
            Text(category.rawValue)
                .font(.ftBody(13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : Color.ftDeepForest.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.ftOlive : Color.white.opacity(0.7))
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    isSelected ? Color.clear : Color.ftSoftClay,
                                    lineWidth: 1
                                )
                        )
                )
        }
        .animation(.easeInOut(duration: 0.15), value: selectedCategory)
    }

    // MARK: - Section

    private func sectionView(category: PantryCategory, items: [PantryDisplayItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section header
            HStack(alignment: .firstTextBaseline) {
                Text(category.rawValue)
                    .font(.ftBody(17, weight: .bold))
                    .foregroundStyle(Color.ftDeepForest)
                Text("\(mockItems.filter { $0.category == category }.count) items")
                    .font(.ftBody(12))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.35))
                Spacer()
                Button("View All") {}
                    .font(.ftBody(13, weight: .medium))
                    .foregroundStyle(Color.ftOlive)
            }
            .padding(.horizontal, 16)

            // Items
            VStack(spacing: 8) {
                ForEach(items) { item in
                    NavigationLink(destination: ProductDetailView(item: item)) {
                        pantryItemRow(item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Item Row

    private func pantryItemRow(_ item: PantryDisplayItem) -> some View {
        HStack(spacing: 12) {
            // Thumbnail
            ProductImage(
                urlString: item.imageURL,
                fallbackIcon: item.iconName,
                fallbackBg: item.iconBg,
                cornerRadius: 10
            )
            .frame(width: 56, height: 56)

            // Name + detail
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.ftBody(15, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                Text(item.detail)
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest50)
            }

            Spacer()

            // Badge
            Text(item.badge.label)
                .font(.ftBody(10, weight: .bold))
                .foregroundStyle(item.badge.labelColor)
                .kerning(0.4)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(item.badge.bgColor)
                )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                )
        )
        .ftShadowSm()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "refrigerator")
                .font(.system(size: 40))
                .foregroundStyle(Color.ftDeepForest.opacity(0.2))
            Text("No items found")
                .font(.ftBody(16, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    PantryView()
}
