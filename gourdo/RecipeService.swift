//
//  RecipeService.swift
//  gourdo
//
//  Calls the generate-recipe Edge Function (which proxies to Claude API server-side).
//  The Claude API key never leaves the server.
//

import Foundation
import Supabase

enum RecipeServiceError: LocalizedError {
    case noItems
    case rateLimited
    case badResponse(Int)
    case emptyContent
    case parseFailure

    var errorDescription: String? {
        switch self {
        case .noItems:             return "Select at least one ingredient."
        case .rateLimited:         return "Monthly generation limit reached. Resets at the start of next month."
        case .badResponse(let code): return "Server error (\(code)). Please try again."
        case .emptyContent:        return "No recipe was returned. Please try again."
        case .parseFailure:        return "Could not parse the recipe. Please try again."
        }
    }
}

struct RecipeGenerationResult {
    let recipe: GeneratedRecipe
    let promptTokens: Int
    let completionTokens: Int
}

struct RecipeService {

    static func generate(from items: [PantryItem]) async throws -> RecipeGenerationResult {
        guard !items.isEmpty else { throw RecipeServiceError.noItems }

        // Build ingredient payload for the Edge Function
        struct Ingredient: Encodable {
            let name: String
            let quantityDisplay: String
            let brand: String?
            let daysUntilExpiry: Int?
        }

        struct RequestBody: Encodable {
            let ingredients: [Ingredient]
        }

        let ingredients = items.map { item in
            Ingredient(
                name: item.name,
                quantityDisplay: item.quantityDisplay,
                brand: item.brand,
                daysUntilExpiry: item.daysUntilExpiry
            )
        }

        let body = RequestBody(ingredients: ingredients)

        // Call the Edge Function via Supabase client (auth header sent automatically)
        let response: EdgeFunctionResponse = try await supabase.functions.invoke(
            "generate-recipe",
            options: .init(body: body)
        )

        // Build the recipe from the response
        let usesExpiring = items.contains { ($0.daysUntilExpiry ?? Int.max) <= 3 }

        let ingredientHash = items
            .map { $0.name.lowercased().trimmingCharacters(in: .whitespaces) }
            .sorted()
            .joined(separator: ",")

        let modelUsed = response.model ?? ""

        let recipe = GeneratedRecipe(
            title:           response.recipe.title,
            prepTime:        response.recipe.prepTime,
            difficulty:      response.recipe.difficulty,
            heroImageURL:    "",
            ingredients:     response.recipe.ingredients,
            steps:           response.recipe.steps,
            usesExpiring:    usesExpiring,
            ingredientHash:  ingredientHash,
            promptTokens:    response.usage?.inputTokens ?? 0,
            completionTokens: response.usage?.outputTokens ?? 0,
            modelUsed:       modelUsed,
            generatedAt:     Date()
        )

        return RecipeGenerationResult(
            recipe:           recipe,
            promptTokens:     response.usage?.inputTokens ?? 0,
            completionTokens: response.usage?.outputTokens ?? 0
        )
    }
}

// MARK: - Edge Function Response

private struct EdgeFunctionResponse: Decodable {
    let recipe: RecipePayload
    let usage: UsagePayload?
    let model: String?
    let remaining: Int?
}

private struct RecipePayload: Decodable {
    let title: String
    let prepTime: String
    let difficulty: String
    let ingredients: [String]
    let steps: [String]
}

private struct UsagePayload: Decodable {
    let inputTokens: Int
    let outputTokens: Int
}
