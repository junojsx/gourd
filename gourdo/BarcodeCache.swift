//
//  BarcodeCache.swift
//  gourdo
//

import Foundation

private struct BarcodeCacheEntry: Codable {
    let barcode: String
    let name: String
    let brand: String?
    let imageURL: String?
    let quantity: String?
    let rawCategory: String?
    let cachedAt: Date
}

enum BarcodeCache {
    private static let ttl: TimeInterval = 30 * 24 * 60 * 60
    private static let key = "barcode_lookup_cache"

    static func get(_ barcode: String) -> ScannedProduct? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let dict = try? JSONDecoder().decode([String: BarcodeCacheEntry].self, from: data),
              let entry = dict[barcode]
        else { return nil }

        guard Date().timeIntervalSince(entry.cachedAt) < ttl else { return nil }

        return ScannedProduct(
            barcode: entry.barcode,
            name: entry.name,
            brand: entry.brand,
            imageURL: entry.imageURL,
            quantity: entry.quantity,
            rawCategory: entry.rawCategory
        )
    }

    static func set(_ product: ScannedProduct) {
        var dict = loadDict()
        dict[product.barcode] = BarcodeCacheEntry(
            barcode: product.barcode,
            name: product.name,
            brand: product.brand,
            imageURL: product.imageURL,
            quantity: product.quantity,
            rawCategory: product.rawCategory,
            cachedAt: Date()
        )
        saveDict(dict)
    }

    static func evictExpired() {
        var dict = loadDict()
        let now = Date()
        dict = dict.filter { now.timeIntervalSince($0.value.cachedAt) < ttl }
        saveDict(dict)
    }

    private static func loadDict() -> [String: BarcodeCacheEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let dict = try? JSONDecoder().decode([String: BarcodeCacheEntry].self, from: data)
        else { return [:] }
        return dict
    }

    private static func saveDict(_ dict: [String: BarcodeCacheEntry]) {
        guard let data = try? JSONEncoder().encode(dict) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
