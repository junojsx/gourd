//
//  RecipeService.swift
//  gourd
//
//  Calls the Claude API to generate a recipe from selected pantry items.
//

import Foundation

enum RecipeServiceError: LocalizedError {
    case noItems
    case badResponse(Int)
    case emptyContent
    case parseFailure

    var errorDescription: String? {
        switch self {
        case .noItems:          return "Select at least one ingredient."
        case .badResponse(let code): return "API error \(code). Check your API key in Secrets.swift."
        case .emptyContent:     return "Claude returned an empty response."
        case .parseFailure:     return "Could not parse the recipe. Please try again."
        }
    }
}

struct RecipeGenerationResult {
    let recipe: GeneratedRecipe
    let promptTokens: Int
    let completionTokens: Int
}

struct RecipeService {

    static let modelName = "claude-haiku-4-5-20251001"

    static func generate(from items: [PantryItem]) async throws -> RecipeGenerationResult {
        guard !items.isEmpty else { throw RecipeServiceError.noItems }

        let ingredientLines = items.map { item -> String in
            var line = "- \(item.name): \(item.quantityDisplay)"
            if let brand = item.brand { line += " (\(brand))" }
            if let days = item.daysUntilExpiry, days <= 3 { line += " [expiring soon]" }
            return line
        }.joined(separator: "\n")

        let prompt = """
        You are a creative chef helping someone use up their pantry items.

        Available ingredients:
        \(ingredientLines)

        Create a delicious recipe using ONLY the above ingredients (you may assume basic pantry staples like salt, pepper, water, and oil are available).

        Respond with ONLY a valid JSON object — no markdown, no explanation, no code fences:
        {
          "title": "Recipe Name",
          "prepTime": "X mins",
          "difficulty": "Easy",
          "ingredients": ["amount + ingredient", "amount + ingredient"],
          "steps": ["Step description.", "Step description."]
        }

        Rules:
        - title: appetising and specific
        - difficulty: exactly "Easy", "Medium", or "Hard"
        - ingredients: 4–8 items with specific amounts
        - steps: 4–6 clear, actionable instructions
        """

        struct AnthropicRequest: Encodable {
            struct Message: Encodable {
                let role: String
                let content: String
            }
            let model: String
            let maxTokens: Int
            let messages: [Message]
            enum CodingKeys: String, CodingKey {
                case model
                case maxTokens = "max_tokens"
                case messages
            }
        }

        let body = AnthropicRequest(
            model: modelName,
            maxTokens: 1024,
            messages: [.init(role: "user", content: prompt)]
        )

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json",   forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01",         forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            print("❌ Anthropic \(http.statusCode):", String(data: data, encoding: .utf8) ?? "no body")
            throw RecipeServiceError.badResponse(http.statusCode)
        }

        // Decode Anthropic response envelope (includes token usage)
        struct Envelope: Decodable {
            struct Block: Decodable { let text: String }
            struct Usage: Decodable {
                let inputTokens: Int
                let outputTokens: Int
                enum CodingKeys: String, CodingKey {
                    case inputTokens  = "input_tokens"
                    case outputTokens = "output_tokens"
                }
            }
            let content: [Block]
            let usage: Usage
        }
        let envelope = try JSONDecoder().decode(Envelope.self, from: data)
        guard let text = envelope.content.first?.text, !text.isEmpty else {
            throw RecipeServiceError.emptyContent
        }

        // Extract the JSON object from the text
        guard
            let start = text.firstIndex(of: "{"),
            let end   = text.lastIndex(of: "}")
        else { throw RecipeServiceError.parseFailure }

        let jsonData = Data(text[start...end].utf8)

        struct RecipePayload: Decodable {
            let title: String
            let prepTime: String
            let difficulty: String
            let ingredients: [String]
            let steps: [String]
        }

        let payload = try JSONDecoder().decode(RecipePayload.self, from: jsonData)

        // Determine whether any selected items were expiring (within 3 days)
        let usesExpiring = items.contains { ($0.daysUntilExpiry ?? Int.max) <= 3 }

        // Build a stable ingredient hash for cache lookup
        let ingredientHash = items
            .map { $0.name.lowercased().trimmingCharacters(in: .whitespaces) }
            .sorted()
            .joined(separator: ",")

        let recipe = GeneratedRecipe(
            title:           payload.title,
            prepTime:        payload.prepTime,
            difficulty:      payload.difficulty,
            heroImageURL:    "",
            ingredients:     payload.ingredients,
            steps:           payload.steps,
            usesExpiring:    usesExpiring,
            ingredientHash:  ingredientHash,
            promptTokens:    envelope.usage.inputTokens,
            completionTokens: envelope.usage.outputTokens,
            modelUsed:       modelName,
            generatedAt:     Date()
        )
        return RecipeGenerationResult(
            recipe:           recipe,
            promptTokens:     envelope.usage.inputTokens,
            completionTokens: envelope.usage.outputTokens
        )
    }
}
