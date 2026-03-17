//
//  RecipesView.swift
//  gourd
//

import SwiftUI

// MARK: - Ingredient Models

struct RecipeIngredientItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let group: IngredientGroup
}

enum IngredientGroup: String, CaseIterable {
    case dairyEggs     = "DAIRY & EGGS"
    case freshProduce  = "FRESH PRODUCE"
    case pantryStaples = "PANTRY STAPLES"
}

struct GeneratedRecipe: Identifiable, Codable {
    let id: UUID
    let title: String
    let prepTime: String
    let difficulty: String
    let heroImageURL: String
    let ingredients: [String]
    let steps: [String]

    // Metadata for Supabase persistence
    var usesExpiring: Bool
    var ingredientHash: String
    var promptTokens: Int
    var completionTokens: Int
    var modelUsed: String
    var generatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        prepTime: String,
        difficulty: String,
        heroImageURL: String,
        ingredients: [String],
        steps: [String],
        usesExpiring: Bool = false,
        ingredientHash: String = "",
        promptTokens: Int = 0,
        completionTokens: Int = 0,
        modelUsed: String = "",
        generatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.prepTime = prepTime
        self.difficulty = difficulty
        self.heroImageURL = heroImageURL
        self.ingredients = ingredients
        self.steps = steps
        self.usesExpiring = usesExpiring
        self.ingredientHash = ingredientHash
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.modelUsed = modelUsed
        self.generatedAt = generatedAt
    }
}

// MARK: - Mock Data

private let allIngredients: [RecipeIngredientItem] = [
    // Dairy & Eggs
    .init(name: "Greek Yogurt",    description: "Full fat, Organic",      group: .dairyEggs),
    .init(name: "Whole Milk",      description: "1/2 gallon remaining",   group: .dairyEggs),
    .init(name: "Cheddar Cheese",  description: "Block, Sharp",           group: .dairyEggs),
    .init(name: "Eggs",            description: "Large, free range",      group: .dairyEggs),
    .init(name: "Butter",          description: "Unsalted",               group: .dairyEggs),

    // Fresh Produce
    .init(name: "Spinach",         description: "Fresh, Baby leaves",     group: .freshProduce),
    .init(name: "Bell Peppers",    description: "Red & Yellow",           group: .freshProduce),
    .init(name: "Avocado",         description: "Ripe",                   group: .freshProduce),
    .init(name: "Roma Tomatoes",   description: "4 pieces",               group: .freshProduce),
    .init(name: "Broccoli",        description: "1 head",                 group: .freshProduce),
    .init(name: "Valencia Oranges",description: "6 units",                group: .freshProduce),

    // Pantry Staples
    .init(name: "Jasmine Rice",    description: "5 lbs bag",              group: .pantryStaples),
    .init(name: "Olive Oil",       description: "Extra virgin, 750ml",    group: .pantryStaples),
    .init(name: "Pasta",           description: "500g, penne",            group: .pantryStaples),
    .init(name: "Garlic",          description: "Fresh bulb",             group: .pantryStaples),
]

private let recipePool: [GeneratedRecipe] = [
    GeneratedRecipe(
        title: "Roasted Mediterranean Harvest Bowl",
        prepTime: "25 mins",
        difficulty: "Medium",
        heroImageURL: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80&auto=format&fit=crop",
        ingredients: [
            "2 cups roasted chickpeas",
            "1 large sweet potato, cubed",
            "1/2 red onion, sliced",
            "Fresh kale & tahini dressing"
        ],
        steps: [
            "Preheat your oven to 400°F (200°C). Toss the cubed sweet potatoes and chickpeas in olive oil, cumin, and salt.",
            "Spread on a baking sheet and roast for 20 minutes until the potatoes are tender and chickpeas are crispy.",
            "Massage the kale with a bit of lemon juice. Assemble the bowl by layering kale, roasted veggies, and onion.",
            "Drizzle generously with tahini dressing and top with sesame seeds if desired."
        ]
    ),
    GeneratedRecipe(
        title: "Creamy Spinach & Cheddar Pasta",
        prepTime: "20 mins",
        difficulty: "Easy",
        heroImageURL: "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800&q=80&auto=format&fit=crop",
        ingredients: [
            "200g penne pasta",
            "2 cups fresh baby spinach",
            "1/2 cup shredded cheddar cheese",
            "2 tbsp olive oil",
            "Salt & pepper to taste"
        ],
        steps: [
            "Cook pasta in salted boiling water until al dente, about 8–10 minutes. Reserve 1/2 cup pasta water before draining.",
            "Heat olive oil in a pan over medium heat. Add spinach and cook until wilted, about 2 minutes.",
            "Add drained pasta to the pan. Stir in cheese and a splash of pasta water until creamy.",
            "Season with salt and pepper. Serve immediately with extra cheese on top."
        ]
    ),
    GeneratedRecipe(
        title: "Greek Yogurt Veggie Power Bowl",
        prepTime: "10 mins",
        difficulty: "Easy",
        heroImageURL: "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&q=80&auto=format&fit=crop",
        ingredients: [
            "1 cup Greek yogurt, full fat",
            "1 cup mixed bell peppers, diced",
            "1/2 avocado, sliced",
            "Drizzle of olive oil",
            "Fresh herbs to garnish"
        ],
        steps: [
            "Spread Greek yogurt on a wide bowl as a creamy base.",
            "Dice the bell peppers and arrange on top along with sliced avocado.",
            "Drizzle with olive oil and season with salt, pepper, and fresh herbs.",
            "Serve immediately as a light, protein-rich meal."
        ]
    ),
]

// Two recipes pre-saved so the list isn't empty on first launch
private let mockSavedRecipes: [GeneratedRecipe] = [
    recipePool[1], recipePool[2]
]

// MARK: - RecipesTabView

extension Notification.Name {
    static let savedRecipesDidChange = Notification.Name("savedRecipesDidChange")
}

struct RecipesTabView: View {
    @Environment(PantryRepository.self) private var repo
    @Environment(RecipeRepository.self) private var recipeRepo
    @State private var navigateToCreate = false
    @State private var saveError: String?

    private var savedRecipes: [GeneratedRecipe] { recipeRepo.recipes }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.ftWarmBeige.ignoresSafeArea()

                VStack(spacing: 0) {
                    navBar

                    if savedRecipes.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(savedRecipes) { recipe in
                                    NavigationLink(destination: RecipeResultView(
                                        recipe: recipe,
                                        onSave: nil,
                                        onDiscard: nil,
                                        onUpdate: { updated in
                                            Task {
                                                do { try await recipeRepo.update(updated) }
                                                catch { saveError = error.localizedDescription }
                                            }
                                        },
                                        onDelete: {
                                            Task {
                                                do { try await recipeRepo.delete(recipe.id) }
                                                catch { saveError = error.localizedDescription }
                                            }
                                        }
                                    )) {
                                        recipeCard(recipe)
                                    }
                                    .buttonStyle(.plain)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            Task {
                                                do { try await recipeRepo.delete(recipe.id) }
                                                catch { saveError = error.localizedDescription }
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 110)
                        }
                    }
                }

                // Create Recipe FAB
                Button(action: { navigateToCreate = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Create Recipe")
                            .font(.ftBody(14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.ftDeepForest))
                    .ftShadowMd()
                }
                .padding(.trailing, 20)
                .padding(.bottom, 98)
            }
            .navigationDestination(isPresented: $navigateToCreate) {
                CreateRecipeView { recipe in
                    Task {
                        do { try await recipeRepo.save(recipe) }
                        catch { saveError = error.localizedDescription }
                    }
                }
                .environment(repo)
                .environment(recipeRepo)
            }
            .alert("Couldn't Save Recipe", isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK") { saveError = nil }
            } message: {
                Text(saveError ?? "")
            }
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
                    Image(systemName: "book.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                }
                Text("My Recipes")
                    .font(.ftBody(19, weight: .bold))
                    .foregroundStyle(Color.ftDeepForest)
            }
            Spacer()
            Text("\(savedRecipes.count) saved")
                .font(.ftBody(13))
                .foregroundStyle(Color.ftDeepForest.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.ftWarmBeige)
    }

    // MARK: - Recipe Card

    private func recipeCard(_ recipe: GeneratedRecipe) -> some View {
        HStack(spacing: 12) {
            ProductImage(
                urlString: recipe.heroImageURL,
                fallbackIcon: "fork.knife",
                fallbackBg: Color.ftSoftClay.opacity(0.3),
                cornerRadius: 10
            )
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title)
                    .font(.ftBody(15, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 14) {
                    Label(recipe.prepTime, systemImage: "clock")
                    Label(recipe.difficulty, systemImage: "chart.bar.fill")
                }
                .font(.ftBody(12))
                .foregroundStyle(Color.ftDeepForest50)

                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9, weight: .bold))
                    Text("AI GENERATED")
                        .font(.ftBody(9, weight: .bold))
                        .kerning(0.4)
                }
                .foregroundStyle(Color.ftOlive)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.ftOlive.opacity(0.1))
                        .overlay(Capsule().strokeBorder(Color.ftOlive.opacity(0.3), lineWidth: 1))
                )
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.ftDeepForest.opacity(0.25))
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

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "book.closed")
                .font(.system(size: 44))
                .foregroundStyle(Color.ftDeepForest.opacity(0.15))
            Text("No saved recipes yet")
                .font(.ftBody(16, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest.opacity(0.4))
            Text("Tap \"Create Recipe\" to generate\nyour first AI recipe.")
                .font(.ftBody(13))
                .foregroundStyle(Color.ftDeepForest.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - CreateRecipeView

struct CreateRecipeView: View {
    let onSave: (GeneratedRecipe) -> Void

    @Environment(PantryRepository.self) private var repo
    @State private var selectedIDs:     Set<UUID> = []
    @State private var searchText       = ""
    @State private var isGenerating     = false
    @FocusState private var isSearchFocused: Bool
    @State private var generatedRecipe: GeneratedRecipe?
    @State private var navigateToResult = false
    @State private var generationError: String?
    @Environment(\.dismiss) private var dismiss

    private var filteredGroups: [(ItemCategory, [PantryItem])] {
        ItemCategory.allCases.compactMap { category in
            let items = repo.items.filter {
                $0.category == category &&
                (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText))
            }
            return items.isEmpty ? nil : (category, items)
        }
    }

    private var selectedItems: [PantryItem] {
        repo.items.filter { selectedIDs.contains($0.id) }
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

    var body: some View {
        ZStack {
            Color.ftWarmBeige.ignoresSafeArea()

            VStack(spacing: 0) {
                customNavBar

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                        searchBar
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        if repo.items.isEmpty {
                            pantryEmptyState
                        } else {
                            ForEach(filteredGroups, id: \.0) { category, items in
                                ingredientGroupView(category, items: items)
                                    .padding(.top, 24)
                            }
                        }
                    }
                    .padding(.bottom, 110)
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
            if !selectedIDs.isEmpty && !isGenerating {
                generateButton
                    .padding(.bottom, 80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedIDs.isEmpty)
        .alert("Couldn't Generate Recipe", isPresented: Binding(
            get: { generationError != nil },
            set: { if !$0 { generationError = nil } }
        )) {
            Button("OK") { generationError = nil }
        } message: {
            Text(generationError ?? "")
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToResult) {
            if let recipe = generatedRecipe {
                RecipeResultView(
                    recipe: recipe,
                    onSave: { savedRecipe in
                        onSave(savedRecipe)
                    },
                    onDiscard: {
                        selectedIDs = []
                        navigateToResult = false
                    }
                )
            }
        }
    }

    // MARK: - Custom Nav Bar

    private var customNavBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
            }
            Spacer()
            Text("Create Recipe")
                .font(.ftBody(17, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest)
            Spacer()
            // Balance the back button
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.clear)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.ftWarmBeige)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("What's in your pantry?")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundStyle(Color.ftDeepForest)
            Text("Select ingredients to generate a custom AI recipe.")
                .font(.ftBody(14))
                .foregroundStyle(Color.ftDeepForest50)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Color.ftDeepForest.opacity(0.35))
            TextField("", text: $searchText, prompt: Text("Search ingredients...").foregroundStyle(Color.ftPlaceholder))
                .font(.ftBody(15))
                .foregroundStyle(Color.ftDeepForest)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isSearchFocused)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.ftDeepForest.opacity(0.3))
                }
            } else {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.35))
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
    }

    // MARK: - Pantry Empty State

    private var pantryEmptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "refrigerator")
                .font(.system(size: 40))
                .foregroundStyle(Color.ftDeepForest.opacity(0.15))
            Text("Your pantry is empty")
                .font(.ftBody(16, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest.opacity(0.4))
            Text("Add items to your pantry first,\nthen come back to generate a recipe.")
                .font(.ftBody(13))
                .foregroundStyle(Color.ftDeepForest.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.horizontal, 40)
    }

    // MARK: - Ingredient Group

    private func ingredientGroupView(_ category: ItemCategory, items: [PantryItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.displayName.uppercased())
                    .font(.ftBody(11, weight: .bold))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.5))
                    .kerning(1.0)
                Spacer()
                Text("\(items.count) ITEMS")
                    .font(.ftBody(10, weight: .medium))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.35))
                    .kerning(0.5)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    ingredientRow(item)
                    if index < items.count - 1 {
                        Divider()
                            .background(Color.ftSoftClay.opacity(0.5))
                            .padding(.leading, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
        }
    }

    private func ingredientRow(_ item: PantryItem) -> some View {
        let isSelected = selectedIDs.contains(item.id)
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                if isSelected { selectedIDs.remove(item.id) }
                else { selectedIDs.insert(item.id) }
            }
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.ftBody(15, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                    Text(item.quantityDisplay + (item.brand.map { " · \($0)" } ?? ""))
                        .font(.ftBody(13))
                        .foregroundStyle(Color.ftDeepForest50)
                }
                Spacer()
                if item.freshnessGrade == .urgent || item.freshnessGrade == .expired {
                    Text(item.freshnessGrade.badgeLabel)
                        .font(.ftBody(9, weight: .bold))
                        .foregroundStyle(item.freshnessGrade.badgeLabelColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(RoundedRectangle(cornerRadius: 4).fill(item.freshnessGrade.badgeBgColor))
                }
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color.ftOlive : Color.ftDeepForest.opacity(0.22))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        VStack(spacing: 0) {
            Text("\(RecipeRateLimiter.remaining) of \(RecipeRateLimiter.maxPerMonth) generations left this month")
                .font(.ftBody(11))
                .foregroundStyle(Color.ftDeepForest.opacity(0.45))
                .padding(.top, 12)
                .padding(.bottom, 10)

            Button(action: generateRecipe) {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Generate AI Recipe")
                        .font(.ftBody(15, weight: .semibold))
                    Spacer()
                    Text("\(selectedIDs.count) ingredient\(selectedIDs.count == 1 ? "" : "s")")
                        .font(.ftBody(12, weight: .bold))
                        .foregroundStyle(Color.ftDeepForest)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.ftWarmBeige))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(RecipeRateLimiter.canGenerate ? Color.ftDeepForest : Color.ftDeepForest.opacity(0.35))
            }
        }
        .background(Color.ftWarmBeige)
    }
}

// MARK: - RecipeResultView

struct RecipeResultView: View {
    /// Called when the user saves. Nil when viewing a pre-saved recipe.
    let onSave: ((GeneratedRecipe) -> Void)?
    /// Called when the user discards. Nil when viewing a pre-saved recipe.
    let onDiscard: (() -> Void)?
    /// Called when the user updates (edits) a saved recipe. Nil when generating a new recipe.
    let onUpdate: ((GeneratedRecipe) -> Void)?
    /// Called when the user deletes a saved recipe. Nil when generating a new recipe.
    let onDelete: (() -> Void)?

    @State private var currentRecipe: GeneratedRecipe
    @State private var isSaved: Bool
    @State private var showDeleteConfirm = false
    @State private var navigateToEdit = false
    @Environment(\.dismiss) private var dismiss

    init(recipe: GeneratedRecipe, onSave: ((GeneratedRecipe) -> Void)?, onDiscard: (() -> Void)?,
         onUpdate: ((GeneratedRecipe) -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.onSave = onSave
        self.onDiscard = onDiscard
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _currentRecipe = State(initialValue: recipe)
        // Pre-saved recipes start in saved state
        _isSaved = State(initialValue: onSave == nil)
    }

    var body: some View {
        Color.ftWarmBeige.ignoresSafeArea()
            .overlay(
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        heroImage

                        VStack(alignment: .leading, spacing: 20) {
                            aiBadge
                            Text(currentRecipe.title)
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundStyle(Color.ftDeepForest)
                            metaRow

                            sectionHeader(icon: "basket.fill", label: "Ingredients Used")
                            ingredientsList

                            sectionHeader(icon: "scissors", label: "Instructions")
                            instructionsList
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
            )
            .safeAreaInset(edge: .bottom) {
                actionButtons
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
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
                    Text("AI Recipe Result")
                        .font(.ftBody(17, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                }
                if onUpdate != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { navigateToEdit = true }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.ftDeepForest)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToEdit) {
                EditRecipeView(recipe: currentRecipe) { updated in
                    currentRecipe = updated
                    onUpdate?(updated)
                }
            }
            .toolbarBackground(Color.ftWarmBeige, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
    }

    // MARK: Hero

    private var heroImage: some View {
        RecipeHeroImage(urlString: currentRecipe.heroImageURL, height: 220)
    }

    // MARK: AI Badge

    private var aiBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .bold))
            Text("AI GENERATED")
                .font(.ftBody(10, weight: .bold))
                .kerning(0.5)
        }
        .foregroundStyle(Color.ftOlive)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.ftOlive.opacity(0.1))
                .overlay(Capsule().strokeBorder(Color.ftOlive.opacity(0.3), lineWidth: 1))
        )
    }

    // MARK: Meta Row

    private var metaRow: some View {
        HStack(spacing: 28) {
            metaCell(icon: "clock", label: "PREP TIME",  value: currentRecipe.prepTime)
            metaCell(icon: "chart.bar.fill", label: "DIFFICULTY", value: currentRecipe.difficulty)
        }
    }

    private func metaCell(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.ftOlive)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.ftBody(10, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.4))
                    .kerning(0.5)
                Text(value)
                    .font(.ftBody(13, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
            }
        }
    }

    // MARK: Section Header

    private func sectionHeader(icon: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(Color.ftDeepForest)
            Text(label)
                .font(.ftBody(16, weight: .bold))
                .foregroundStyle(Color.ftDeepForest)
        }
    }

    // MARK: Ingredients

    private var ingredientsList: some View {
        VStack(spacing: 8) {
            ForEach(currentRecipe.ingredients, id: \.self) { ingredient in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.ftDeepForest)
                        .frame(width: 6, height: 6)
                    Text(ingredient)
                        .font(.ftBody(14))
                        .foregroundStyle(Color.ftDeepForest)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.ftSoftClay.opacity(0.4), lineWidth: 1)
                        )
                )
            }
        }
    }

    // MARK: Instructions

    private var instructionsList: some View {
        VStack(spacing: 14) {
            ForEach(Array(currentRecipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.ftDeepForest))
                    Text(step)
                        .font(.ftBody(14))
                        .foregroundStyle(Color.ftDeepForest)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }
        }
    }

    // MARK: Action Buttons

    private var actionButtons: some View {
        Group {
            if let onSave, let onDiscard {
                // Viewing a newly generated recipe — show Save + Discard
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation { isSaved = true }
                        onSave(currentRecipe)
                        // Navigate back after a brief moment so the user sees "Saved!"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 14, weight: .semibold))
                            Text(isSaved ? "Saved!" : "Save Recipe")
                                .font(.ftBody(15, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSaved ? Color.ftOlive : Color.ftDeepForest)
                        )
                    }
                    .disabled(isSaved)

                    Button(action: { onDiscard(); dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Discard")
                                .font(.ftBody(15, weight: .semibold))
                        }
                        .foregroundStyle(Color.ftDeepForest)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.ftSoftClay, lineWidth: 1)
                                )
                        )
                    }
                }
            } else {
                // Viewing a pre-saved recipe — saved indicator + delete
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Saved")
                            .font(.ftBody(15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.ftOlive)
                    )

                    Button(action: { showDeleteConfirm = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Delete")
                                .font(.ftBody(15, weight: .semibold))
                        }
                        .foregroundStyle(Color.ftCrimson)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.ftCrimson.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.ftCrimson.opacity(0.4), lineWidth: 1)
                                )
                        )
                    }
                    .confirmationDialog("Delete this recipe?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                        Button("Delete Recipe", role: .destructive) {
                            onDelete?()
                            dismiss()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This recipe will be removed from My Recipes.")
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSaved)
    }
}

#Preview {
    RecipesTabView()
}
