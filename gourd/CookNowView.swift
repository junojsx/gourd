//
//  CookNowView.swift
//  gourd
//
//  Full-screen Cook Now modal: select expiring pantry items → generate recipe.
//

import SwiftUI

struct CookNowView: View {
    let filter: CookNowFilter?

    @Environment(PantryRepository.self) private var repo
    @Environment(RecipeRepository.self) private var recipeRepo
    @Environment(\.dismiss) private var dismiss

    @State private var selectedIds: Set<UUID> = []
    @State private var activeWindow: ExpiryWindow = .all
    @State private var isGenerating = false
    @State private var generatedRecipe: GeneratedRecipe?
    @State private var navigateToResult = false
    @State private var generationError: String?

    // All non-consumed items that have an expiry date, sorted soonest first.
    // The "All" window shows all of them; narrower windows filter client-side.
    private var expiringItems: [PantryItem] {
        repo.items
            .filter { !$0.isConsumed && $0.daysUntilExpiry != nil }
            .sorted { ($0.daysUntilExpiry ?? Int.max) < ($1.daysUntilExpiry ?? Int.max) }
    }

    private var filteredItems: [PantryItem] {
        switch activeWindow {
        case .all:      return expiringItems
        default:        return expiringItems.filter { activeWindow.contains(daysUntilExpiry: $0.daysUntilExpiry ?? Int.max) }
        }
    }

    private var selectedItems: [PantryItem] {
        repo.items.filter { selectedIds.contains($0.id) }
    }

    var body: some View {
        ZStack {
            Color.ftWarmBeige.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                // Window picker
                windowPicker
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                // Item count subtitle
                Text(subtitleText)
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)

                Divider()
                    .background(Color.ftSoftClay.opacity(0.5))

                // Item list
                if expiringItems.isEmpty {
                    emptyState
                } else if filteredItems.isEmpty {
                    windowEmptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            ForEach(filteredItems) { item in
                                CookNowItemRow(
                                    item: item,
                                    isSelected: selectedIds.contains(item.id),
                                    onToggle: { toggleSelection(item.id) }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 120)
                    }
                }
            }

            // Loading overlay
            if isGenerating {
                Color.black.opacity(0.45).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Generating your recipe...")
                        .font(.ftBody(15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isGenerating)
        .safeAreaInset(edge: .bottom) {
            if !selectedIds.isEmpty && !isGenerating {
                generateButton
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedIds.isEmpty)
        .alert("Couldn't Generate Recipe", isPresented: Binding(
            get: { generationError != nil },
            set: { if !$0 { generationError = nil } }
        )) {
            Button("OK") { generationError = nil }
        } message: {
            Text(generationError ?? "")
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let recipe = generatedRecipe {
                RecipeResultView(
                    recipe: recipe,
                    onSave: { saved in
                        Task {
                            do { try await recipeRepo.save(saved) }
                            catch { generationError = "Couldn't save: \(error.localizedDescription)" }
                        }
                        dismiss()
                    },
                    onDiscard: {
                        selectedIds = []
                        navigateToResult = false
                    },
                    onRegenerate: {
                        let result = try await RecipeService.generate(from: selectedItems)
                        RecipeRateLimiter.recordGeneration()
                        generatedRecipe = result.recipe
                        return result.recipe
                    }
                )
                .environment(recipeRepo)
            }
        }
        .onAppear { applyFilter() }
        .task { await repo.fetchItems() }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.ftDeepForest.opacity(0.07))
                    )
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.ftOlive)
                Text("Cook Now")
                    .font(.ftBody(17, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
            }

            Spacer()

            // Balance button
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.ftWarmBeige)
    }

    // MARK: - Window Picker

    private var windowPicker: some View {
        HStack(spacing: 0) {
            ForEach(ExpiryWindow.allCases) { window in
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { activeWindow = window } }) {
                    Text(window.displayLabel)
                        .font(.ftBody(13, weight: activeWindow == window ? .semibold : .regular))
                        .foregroundStyle(activeWindow == window ? .white : Color.ftDeepForest.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(activeWindow == window ? Color.ftOlive : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ftCardBg.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                )
        )
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button(action: generateRecipe) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 15, weight: .semibold))
                Text("Generate Recipe (\(selectedIds.count) item\(selectedIds.count == 1 ? "" : "s"))")
                    .font(.ftBody(15, weight: .semibold))
            }
            .foregroundStyle(Color.ftWarmBeige)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.ftDeepForest)
            )
            .ftShadowMd()
        }
        .padding(.horizontal, 16)
        .disabled(selectedIds.isEmpty)
    }

    // MARK: - Empty States

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.ftOlive.opacity(0.3))
            Text("Nothing expiring soon")
                .font(.ftBody(16, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest.opacity(0.4))
            Text("Your pantry looks fresh!\nCome back when items are closer to expiry.")
                .font(.ftBody(13))
                .foregroundStyle(Color.ftDeepForest.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }

    private var windowEmptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "clock")
                .font(.system(size: 40))
                .foregroundStyle(Color.ftDeepForest.opacity(0.2))
            Text("No items in this window")
                .font(.ftBody(15, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest.opacity(0.4))
            Text("Try selecting a wider time window.")
                .font(.ftBody(13))
                .foregroundStyle(Color.ftDeepForest.opacity(0.3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }

    // MARK: - Helpers

    private var subtitleText: String {
        let count = filteredItems.count
        return count == 0
            ? "No items expiring in this window"
            : "\(count) item\(count == 1 ? "" : "s") expiring soon"
    }

    private func toggleSelection(_ id: UUID) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }

    private func applyFilter() {
        guard let filter else { return }
        activeWindow = filter.window
        if !filter.preSelectedIds.isEmpty {
            selectedIds = filter.preSelectedIds
        }
    }

    private func generateRecipe() {
        guard RecipeRateLimiter.canGenerate else {
            generationError = "Monthly generation limit reached. Resets at the start of next month."
            return
        }
        isGenerating = true
        generationError = nil
        Task {
            do {
                let result = try await RecipeService.generate(from: selectedItems)
                RecipeRateLimiter.recordGeneration()
                generatedRecipe = result.recipe
                navigateToResult = true
            } catch {
                generationError = error.localizedDescription
            }
            isGenerating = false
        }
    }
}

#Preview {
    NavigationStack {
        CookNowView(filter: nil)
            .environment(PantryRepository())
    }
}
