//
//  RecipeRepository.swift
//  gourd
//
//  Observable CRUD service for the `recipes` table via Supabase.
//  Keeps a UserDefaults cache so the recipe list is available offline.
//

import Foundation
import Observation
import Supabase

// MARK: - DB Row (read)

/// Maps exactly to the `recipes` table columns returned by Supabase.
private struct RecipeRow: Decodable {
    let id: UUID
    let userId: UUID
    let name: String
    let timeMinutes: Int?
    let servings: Int?
    let difficulty: String
    let tip: String?
    let steps: [String]
    let usesExpiring: Bool
    let ingredientHash: String
    let ingredientsJson: [String]
    let modelUsed: String?
    let promptTokens: Int?
    let completionTokens: Int?
    let generatedAt: String?
    let createdAt: String?
    let heroImageURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId           = "user_id"
        case name
        case timeMinutes      = "time_minutes"
        case servings
        case difficulty
        case tip
        case steps
        case usesExpiring     = "uses_expiring"
        case ingredientHash   = "ingredient_hash"
        case ingredientsJson  = "ingredients_json"
        case modelUsed        = "model_used"
        case promptTokens     = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case generatedAt      = "generated_at"
        case createdAt        = "created_at"
        case heroImageURL     = "hero_image_url"
    }

    func toGeneratedRecipe() -> GeneratedRecipe {
        let date: Date = {
            guard let str = generatedAt ?? createdAt else { return Date() }
            return ISO8601DateFormatter().date(from: str) ?? Date()
        }()

        // Reconstruct "25 mins" style string from stored integer
        let prepTime: String = {
            guard let mins = timeMinutes else { return "" }
            return "\(mins) mins"
        }()

        return GeneratedRecipe(
            id:               id,
            title:            name,
            prepTime:         prepTime,
            difficulty:       difficulty,
            heroImageURL:     heroImageURL ?? "",
            ingredients:      ingredientsJson,
            steps:            steps,
            usesExpiring:     usesExpiring,
            ingredientHash:   ingredientHash,
            promptTokens:     promptTokens ?? 0,
            completionTokens: completionTokens ?? 0,
            modelUsed:        modelUsed ?? "",
            generatedAt:      date
        )
    }
}

// MARK: - DB Insert

/// Sent to Supabase when saving a new recipe.
private struct RecipeInsert: Encodable {
    let id: UUID
    let userId: UUID
    let name: String
    let timeMinutes: Int?
    let servings: Int?
    let difficulty: String
    let tip: String?
    let steps: [String]
    let usesExpiring: Bool
    let ingredientHash: String
    let ingredientsJson: [String]
    let modelUsed: String?
    let promptTokens: Int?
    let completionTokens: Int?
    let generatedAt: String
    let heroImageURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId           = "user_id"
        case name
        case timeMinutes      = "time_minutes"
        case servings
        case difficulty
        case tip
        case steps
        case usesExpiring     = "uses_expiring"
        case ingredientHash   = "ingredient_hash"
        case ingredientsJson  = "ingredients_json"
        case modelUsed        = "model_used"
        case promptTokens     = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case generatedAt      = "generated_at"
        case heroImageURL     = "hero_image_url"
    }

    init(recipe: GeneratedRecipe, userId: UUID) {
        self.id               = recipe.id
        self.userId           = userId
        self.name             = recipe.title
        self.timeMinutes      = Self.parseMinutes(from: recipe.prepTime)
        self.servings         = nil   // not tracked in the UI yet
        self.difficulty       = recipe.difficulty
        self.tip              = nil   // not tracked in the UI yet
        self.steps            = recipe.steps
        self.usesExpiring     = recipe.usesExpiring
        self.ingredientHash   = recipe.ingredientHash
        self.ingredientsJson  = recipe.ingredients
        self.modelUsed        = recipe.modelUsed.isEmpty ? nil : recipe.modelUsed
        self.promptTokens     = recipe.promptTokens == 0 ? nil : recipe.promptTokens
        self.completionTokens = recipe.completionTokens == 0 ? nil : recipe.completionTokens
        self.generatedAt      = ISO8601DateFormatter().string(from: recipe.generatedAt)
        self.heroImageURL     = recipe.heroImageURL.isEmpty ? nil : recipe.heroImageURL
    }

    /// Parses "25 mins" → 25, "1 hour 10 mins" → 70, etc. Returns nil if unparseable.
    private static func parseMinutes(from prepTime: String) -> Int? {
        var total = 0
        let lower = prepTime.lowercased()
        // Match hour component
        if let match = lower.range(of: #"(\d+)\s*h"#, options: .regularExpression) {
            let numStr = lower[match].filter(\.isNumber)
            total += (Int(numStr) ?? 0) * 60
        }
        // Match minute component
        if let match = lower.range(of: #"(\d+)\s*m"#, options: .regularExpression) {
            let numStr = lower[match].filter(\.isNumber)
            total += Int(numStr) ?? 0
        }
        return total > 0 ? total : nil
    }
}

// MARK: - DB Update (editable fields only)

private struct RecipeUpdate: Encodable {
    let name: String
    let timeMinutes: Int?
    let difficulty: String
    let steps: [String]
    let ingredientsJson: [String]
    let heroImageURL: String?

    enum CodingKeys: String, CodingKey {
        case name
        case timeMinutes     = "time_minutes"
        case difficulty
        case steps
        case ingredientsJson = "ingredients_json"
        case heroImageURL    = "hero_image_url"
    }

    init(recipe: GeneratedRecipe) {
        self.name          = recipe.title
        self.timeMinutes   = RecipeInsert.parseMinutesPublic(from: recipe.prepTime)
        self.difficulty    = recipe.difficulty
        self.steps         = recipe.steps
        self.ingredientsJson = recipe.ingredients
        self.heroImageURL  = recipe.heroImageURL.isEmpty ? nil : recipe.heroImageURL
    }
}

// Expose parseMinutes for RecipeUpdate
extension RecipeInsert {
    static func parseMinutesPublic(from prepTime: String) -> Int? {
        var total = 0
        let lower = prepTime.lowercased()
        if let match = lower.range(of: #"(\d+)\s*h"#, options: .regularExpression) {
            let numStr = lower[match].filter(\.isNumber)
            total += (Int(numStr) ?? 0) * 60
        }
        if let match = lower.range(of: #"(\d+)\s*m"#, options: .regularExpression) {
            let numStr = lower[match].filter(\.isNumber)
            total += Int(numStr) ?? 0
        }
        return total > 0 ? total : nil
    }
}

// MARK: - RecipeRepository

@Observable
@MainActor
final class RecipeRepository {

    private(set) var recipes: [GeneratedRecipe] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Cache

    private static let cacheKey = "saved_recipes"

    private static let cacheDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private static let cacheEncoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.cacheKey),
           let cached = try? Self.cacheDecoder.decode([GeneratedRecipe].self, from: data) {
            recipes = cached
        }
    }

    private func persistCache() {
        if let data = try? Self.cacheEncoder.encode(recipes) {
            UserDefaults.standard.set(data, forKey: Self.cacheKey)
        }
        // Notify any legacy observers (RecipesTabView uses .savedRecipesDidChange)
        NotificationCenter.default.post(name: .savedRecipesDidChange, object: nil)
    }

    // MARK: - Fetch

    func fetchAll() async {
        isLoading = true
        errorMessage = nil
        do {
            let rows: [RecipeRow] = try await supabase
                .from("recipes")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            recipes = rows.map { $0.toGeneratedRecipe() }
            persistCache()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ RecipeRepository.fetchAll:", error)
        }
        isLoading = false
    }

    // MARK: - Save

    func save(_ recipe: GeneratedRecipe) async throws {
        let userId = try await supabase.auth.session.user.id
        let insert = RecipeInsert(recipe: recipe, userId: userId)
        let row: RecipeRow = try await supabase
            .from("recipes")
            .insert(insert)
            .select()
            .single()
            .execute()
            .value
        recipes.insert(row.toGeneratedRecipe(), at: 0)
        persistCache()
    }

    // MARK: - Update

    func update(_ recipe: GeneratedRecipe) async throws {
        let update = RecipeUpdate(recipe: recipe)
        let row: RecipeRow = try await supabase
            .from("recipes")
            .update(update)
            .eq("id", value: recipe.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        if let idx = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[idx] = row.toGeneratedRecipe()
        }
        persistCache()
    }

    // MARK: - Delete

    func delete(_ id: UUID) async throws {
        try await supabase
            .from("recipes")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
        recipes.removeAll { $0.id == id }
        persistCache()
    }

    // MARK: - Clear (sign-out)

    func clearCache() {
        recipes = []
        UserDefaults.standard.removeObject(forKey: Self.cacheKey)
    }
}
