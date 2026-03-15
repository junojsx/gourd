//
//  PantryRepository.swift
//  gourd
//
//  Observable CRUD service for pantry_items via Supabase.
//  Inject via .environment(pantryRepo) and access with
//  @Environment(PantryRepository.self).
//

import Foundation
import Observation
import PostgREST
import Supabase

@Observable
@MainActor
final class PantryRepository {

    private(set) var items: [PantryItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Fetch

    func fetchItems() async {
        isLoading = true
        errorMessage = nil
        do {
            items = try await supabase
                .from("pantry_items")
                .select()
                .eq("is_consumed", value: false)
                .order("expiry_date", ascending: true)
                .execute()
                .value
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Create

    @discardableResult
    func addItem(_ insert: PantryItemInsert) async throws -> PantryItem {
        let item: PantryItem = try await supabase
            .from("pantry_items")
            .insert(insert)
            .select()
            .single()
            .execute()
            .value
        insertSorted(item)
        return item
    }

    // MARK: - Update

    func updateItem(_ item: PantryItem) async throws {
        let updated: PantryItem = try await supabase
            .from("pantry_items")
            .update(PantryItemUpdate(from: item))
            .eq("id", value: item.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = updated
        }
    }

    // MARK: - Delete

    func deleteItem(_ id: UUID) async throws {
        try await supabase
            .from("pantry_items")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
        items.removeAll { $0.id == id }
    }

    // MARK: - Mark Consumed

    func markConsumed(_ id: UUID) async throws {
        // The on_item_consumed trigger auto-sets consumed_at
        struct ConsumedPayload: Encodable { let isConsumed = true
            enum CodingKeys: String, CodingKey { case isConsumed = "is_consumed" }
        }
        try await supabase
            .from("pantry_items")
            .update(ConsumedPayload())
            .eq("id", value: id.uuidString)
            .execute()
        items.removeAll { $0.id == id }
    }

    // MARK: - Build Insert

    /// Builds a ready-to-insert struct using the current user's session.
    func makeInsert(
        name: String,
        brand: String? = nil,
        barcode: String? = nil,
        imageUrl: String? = nil,
        category: ItemCategory = .other,
        storageLocation: StorageLocation = .fridge,
        addedVia: AddedVia = .manual,
        quantity: Double = 1.0,
        unit: String = "item",
        expiryDate: Date? = nil
    ) async throws -> PantryItemInsert {
        let userId = try await supabase.auth.session.user.id
        print("🔑 makeInsert userId:", userId.uuidString)
        return PantryItemInsert(
            userId: userId,
            name: name,
            brand: brand,
            barcode: barcode,
            imageUrl: imageUrl,
            category: category,
            storageLocation: storageLocation,
            addedVia: addedVia,
            quantity: quantity,
            unit: unit.isEmpty ? "item" : unit,
            expiryDate: PantryItemInsert.dateString(from: expiryDate),
            purchaseDate: PantryItemInsert.dateString(from: Date())
        )
    }

    // MARK: - Private Helpers

    private func insertSorted(_ item: PantryItem) {
        guard let newExpiry = item.expiryDate else {
            items.append(item)
            return
        }
        let idx = items.firstIndex(where: {
            guard let exp = $0.expiryDate else { return false }
            return exp > newExpiry
        }) ?? items.endIndex
        items.insert(item, at: idx)
    }
}
