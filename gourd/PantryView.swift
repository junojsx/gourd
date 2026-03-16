//
//  PantryView.swift
//  gourd
//

import SwiftUI

// MARK: - PantryView

struct PantryView: View {
    @Environment(PantryRepository.self) private var repo

    @State private var searchText       = ""
    @State private var selectedCategory: ItemCategory? = nil   // nil = All
    @State private var showManualAdd    = false
    @FocusState private var isSearchFocused: Bool

    private var filteredItems: [PantryItem] {
        var items = repo.items
        if let cat = selectedCategory {
            items = items.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return items
    }

    private var groupedItems: [(ItemCategory, [PantryItem])] {
        let categories: [ItemCategory] = selectedCategory.map { [$0] } ?? ItemCategory.allCases
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

                        if repo.isLoading && repo.items.isEmpty {
                            loadingState
                        } else if groupedItems.isEmpty {
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
                .scrollDismissesKeyboard(.interactively)
                .refreshable { await repo.fetchItems() }
            }
            .background(Color.ftWarmBeige.ignoresSafeArea())

            // Manual Add FAB
            Button(action: { showManualAdd = true }) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(Circle().fill(Color.ftDeepForest))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 98)
        }
        .task { await repo.fetchItems() }
        .sheet(isPresented: $showManualAdd) {
            ManualAddItemView()
                .environment(repo)
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
            TextField("", text: $searchText, prompt: Text("Search items in your pantry...").foregroundStyle(Color.ftPlaceholder))
                .font(.ftBody(15))
                .foregroundStyle(Color.ftDeepForest)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isSearchFocused)
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
                filterChip(
                    label: "All Items",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                ForEach(ItemCategory.allCases, id: \.self) { cat in
                    filterChip(
                        label: cat.displayName,
                        isSelected: selectedCategory == cat,
                        action: { selectedCategory = cat }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
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

    private func sectionView(category: ItemCategory, items: [PantryItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(category.displayName)
                    .font(.ftBody(17, weight: .bold))
                    .foregroundStyle(Color.ftDeepForest)
                let totalCount = repo.items.filter { $0.category == category }.count
                Text("\(totalCount) item\(totalCount == 1 ? "" : "s")")
                    .font(.ftBody(12))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.35))
                Spacer()
                Button("View All") {}
                    .font(.ftBody(13, weight: .medium))
                    .foregroundStyle(Color.ftOlive)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 8) {
                ForEach(items) { item in
                    NavigationLink(destination: ProductDetailView(item: item)) {
                        pantryItemRow(item)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { try? await repo.deleteItem(item.id) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            Task { try? await repo.markConsumed(item.id) }
                        } label: {
                            Label("Consumed", systemImage: "checkmark.circle")
                        }
                        .tint(Color.ftOlive)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Item Row

    private func pantryItemRow(_ item: PantryItem) -> some View {
        HStack(spacing: 12) {
            ProductImage(
                urlString: item.imageUrl ?? "",
                fallbackIcon: item.category.systemImage,
                fallbackBg: item.category.iconBgColor,
                cornerRadius: 10
            )
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.ftBody(15, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                Text(item.quantityDisplay)
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest50)
            }

            Spacer()

            Text(item.freshnessGrade.badgeLabel)
                .font(.ftBody(10, weight: .bold))
                .foregroundStyle(item.freshnessGrade.badgeLabelColor)
                .kerning(0.4)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(item.freshnessGrade.badgeBgColor)
                )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                )
        )
        .ftShadowSm()
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(Color.ftOlive)
            Text("Loading your pantry...")
                .font(.ftBody(14))
                .foregroundStyle(Color.ftDeepForest.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "refrigerator")
                .font(.system(size: 40))
                .foregroundStyle(Color.ftDeepForest.opacity(0.2))
            Text(searchText.isEmpty ? "Your pantry is empty" : "No items found")
                .font(.ftBody(16, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest.opacity(0.4))
            if searchText.isEmpty && selectedCategory == nil {
                Text("Tap the scanner button to add your first item")
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.3))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.horizontal, 40)
    }
}

#Preview {
    NavigationStack {
        PantryView()
            .environment(PantryRepository())
    }
}
