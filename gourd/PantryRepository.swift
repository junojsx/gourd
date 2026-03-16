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

    /// Latest items snapshot, readable without an instance (used by NotificationPrefs).
    static private(set) var lastKnownItems: [PantryItem] = []

    // MARK: - Cache

    private static let cacheKey = "pantry_items_cache"

    private static let cacheEncoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private static let cacheDecoder: JSONDecoder = {
        JSONDecoder()  // PantryItem uses its own custom init(from:) for date parsing
    }()

    init() {
        // Load cached items immediately so the UI isn't blank while the network call is in flight
        if let data = UserDefaults.standard.data(forKey: Self.cacheKey),
           let cached = try? Self.cacheDecoder.decode([PantryItem].self, from: data) {
            items = cached
        }
    }

    private func persistCache() {
        if let data = try? Self.cacheEncoder.encode(items) {
            UserDefaults.standard.set(data, forKey: Self.cacheKey)
        }
        Self.lastKnownItems = items
    }

    func clearCache() {
        items = []
        UserDefaults.standard.removeObject(forKey: Self.cacheKey)
    }

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
            persistCache()
            await ExpiryNotificationScheduler.shared.reschedule(items: items)
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
        persistCache()
        await ExpiryNotificationScheduler.shared.reschedule(items: items)
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
        persistCache()
        await ExpiryNotificationScheduler.shared.reschedule(items: items)
    }

    // MARK: - Delete

    func deleteItem(_ id: UUID) async throws {
        try await supabase
            .from("pantry_items")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
        items.removeAll { $0.id == id }
        persistCache()
        await ExpiryNotificationScheduler.shared.reschedule(items: items)
    }

    // MARK: - Mark Consumed

    func markConsumed(_ id: UUID) async throws {
        struct ConsumedPayload: Encodable {
            let isConsumed = true
            let consumedAt: String
            enum CodingKeys: String, CodingKey {
                case isConsumed = "is_consumed"
                case consumedAt = "consumed_at"
            }
        }
        let now = ISO8601DateFormatter().string(from: Date())
        try await supabase
            .from("pantry_items")
            .update(ConsumedPayload(consumedAt: now))
            .eq("id", value: id.uuidString)
            .execute()
        items.removeAll { $0.id == id }
        persistCache()
        await ExpiryNotificationScheduler.shared.reschedule(items: items)
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
