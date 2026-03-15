//
//  PantryModels.swift
//  gourd
//
//  Codable models matching the Supabase pantry_items schema.
//

import Foundation
import SwiftUI

// MARK: - Flexible Date Decoding

private extension KeyedDecodingContainer {
    /// Decodes a Date from either "yyyy-MM-dd" (Postgres DATE) or ISO 8601 (TIMESTAMPTZ).
    func decodeFlexibleDate(forKey key: Key) throws -> Date? {
        guard let raw = try decodeIfPresent(String.self, forKey: key) else { return nil }

        // Try date-only first ("2026-03-21")
        if raw.count == 10 {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            f.locale = Locale(identifier: "en_US_POSIX")
            if let d = f.date(from: raw) { return d }
        }

        // Try ISO 8601 with fractional seconds ("2026-03-21T12:00:00.000000+00:00")
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: raw) { return d }

        // Try ISO 8601 without fractional seconds
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: raw) { return d }

        return nil
    }
}

// MARK: - Enums

enum ItemCategory: String, Codable, CaseIterable, Sendable {
    case produce
    case dairy
    case meat
    case bakery
    case frozen
    case canned
    case beverage
    case other

    var displayName: String {
        switch self {
        case .produce:  return "Produce"
        case .dairy:    return "Dairy"
        case .meat:     return "Meat"
        case .bakery:   return "Bakery"
        case .frozen:   return "Frozen"
        case .canned:   return "Canned"
        case .beverage: return "Beverages"
        case .other:    return "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .produce:  return "leaf.fill"
        case .dairy:    return "cup.and.saucer.fill"
        case .meat:     return "fork.knife"
        case .bakery:   return "birthday.cake.fill"
        case .frozen:   return "snowflake"
        case .canned:   return "cylinder.fill"
        case .beverage: return "wineglass.fill"
        case .other:    return "shippingbox.fill"
        }
    }

    var iconBgColor: Color {
        switch self {
        case .produce:  return Color(hex: "C8E6C9")
        case .dairy:    return Color(hex: "E8D5C4")
        case .meat:     return Color(hex: "FFCDD2")
        case .bakery:   return Color(hex: "F5E6C8")
        case .frozen:   return Color(hex: "B3E5FC")
        case .canned:   return Color(hex: "F5F0E8")
        case .beverage: return Color(hex: "D4E8D4")
        case .other:    return Color.ftSoftClay.opacity(0.3)
        }
    }

    /// Infer category from an Open Food Facts tag (e.g. "en:dairy-products")
    init(fromOFFTag tag: String?) {
        guard let tag else { self = .other; return }
        let lower = tag.lowercased()
        switch true {
        case lower.contains("dairy") || lower.contains("milk") || lower.contains("cheese") ||
             lower.contains("yogurt") || lower.contains("butter") || lower.contains("cream"):
            self = .dairy
        case lower.contains("meat") || lower.contains("fish") || lower.contains("seafood") ||
             lower.contains("poultry") || lower.contains("chicken") || lower.contains("beef"):
            self = .meat
        case lower.contains("bread") || lower.contains("bakery") || lower.contains("cereal") ||
             lower.contains("pastry") || lower.contains("biscuit") || lower.contains("cracker"):
            self = .bakery
        case lower.contains("frozen"):
            self = .frozen
        case lower.contains("beverage") || lower.contains("drink") || lower.contains("juice") ||
             lower.contains("water") || lower.contains("coffee") || lower.contains("tea") ||
             lower.contains("soda") || lower.contains("wine") || lower.contains("beer"):
            self = .beverage
        case lower.contains("canned") || lower.contains("preserved") || lower.contains("tinned"):
            self = .canned
        case lower.contains("produce") || lower.contains("fruit") || lower.contains("vegetable") ||
             lower.contains("herb") || lower.contains("plant") || lower.contains("fresh"):
            self = .produce
        default:
            self = .other
        }
    }
}

enum StorageLocation: String, Codable, CaseIterable, Sendable {
    case fridge
    case freezer
    case pantry
    case counter

    var displayName: String {
        switch self {
        case .fridge:  return "Fridge"
        case .freezer: return "Freezer"
        case .pantry:  return "Pantry"
        case .counter: return "Counter"
        }
    }

    var systemImage: String {
        switch self {
        case .fridge:  return "refrigerator"
        case .freezer: return "snowflake.fill"
        case .pantry:  return "cabinet.fill"
        case .counter: return "countertop.fill"
        }
    }
}

enum AddedVia: String, Codable, Sendable {
    case manual
    case barcode
    case ocr
}

// MARK: - PantryItem

struct PantryItem: Codable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    var name: String
    var brand: String?
    var barcode: String?
    var imageUrl: String?
    var category: ItemCategory
    var storageLocation: StorageLocation
    var addedVia: AddedVia
    var quantity: Double
    var unit: String
    var expiryDate: Date?
    var purchaseDate: Date?
    var openedDate: Date?
    var freshnessOverrideDays: Int?
    var isConsumed: Bool
    var consumedAt: Date?
    var notes: String?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId                = "user_id"
        case name
        case brand
        case barcode
        case imageUrl              = "image_url"
        case category
        case storageLocation       = "storage_location"
        case addedVia              = "added_via"
        case quantity
        case unit
        case expiryDate            = "expiry_date"
        case purchaseDate          = "purchase_date"
        case openedDate            = "opened_date"
        case freshnessOverrideDays = "freshness_override_days"
        case isConsumed            = "is_consumed"
        case consumedAt            = "consumed_at"
        case notes
        case createdAt             = "created_at"
        case updatedAt             = "updated_at"
    }

    // Custom decoder to handle both "yyyy-MM-dd" (DATE) and ISO 8601 (TIMESTAMPTZ)
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                    = try c.decode(UUID.self, forKey: .id)
        userId                = try c.decode(UUID.self, forKey: .userId)
        name                  = try c.decode(String.self, forKey: .name)
        brand                 = try c.decodeIfPresent(String.self, forKey: .brand)
        barcode               = try c.decodeIfPresent(String.self, forKey: .barcode)
        imageUrl              = try c.decodeIfPresent(String.self, forKey: .imageUrl)
        category              = try c.decode(ItemCategory.self, forKey: .category)
        storageLocation       = try c.decode(StorageLocation.self, forKey: .storageLocation)
        addedVia              = try c.decode(AddedVia.self, forKey: .addedVia)
        quantity              = try c.decode(Double.self, forKey: .quantity)
        unit                  = try c.decode(String.self, forKey: .unit)
        expiryDate            = try c.decodeFlexibleDate(forKey: .expiryDate)
        purchaseDate          = try c.decodeFlexibleDate(forKey: .purchaseDate)
        openedDate            = try c.decodeFlexibleDate(forKey: .openedDate)
        freshnessOverrideDays = try c.decodeIfPresent(Int.self, forKey: .freshnessOverrideDays)
        isConsumed            = try c.decode(Bool.self, forKey: .isConsumed)
        consumedAt            = try c.decodeFlexibleDate(forKey: .consumedAt)
        notes                 = try c.decodeIfPresent(String.self, forKey: .notes)
        createdAt             = try c.decodeFlexibleDate(forKey: .createdAt) ?? Date()
        updatedAt             = try c.decodeFlexibleDate(forKey: .updatedAt) ?? Date()
    }

    // Memberwise init for previews / tests
    init(
        id: UUID, userId: UUID, name: String, brand: String?, barcode: String?,
        imageUrl: String?, category: ItemCategory, storageLocation: StorageLocation,
        addedVia: AddedVia, quantity: Double, unit: String, expiryDate: Date?,
        purchaseDate: Date?, openedDate: Date?, freshnessOverrideDays: Int?,
        isConsumed: Bool, consumedAt: Date?, notes: String?,
        createdAt: Date, updatedAt: Date
    ) {
        self.id = id; self.userId = userId; self.name = name; self.brand = brand
        self.barcode = barcode; self.imageUrl = imageUrl; self.category = category
        self.storageLocation = storageLocation; self.addedVia = addedVia
        self.quantity = quantity; self.unit = unit; self.expiryDate = expiryDate
        self.purchaseDate = purchaseDate; self.openedDate = openedDate
        self.freshnessOverrideDays = freshnessOverrideDays; self.isConsumed = isConsumed
        self.consumedAt = consumedAt; self.notes = notes
        self.createdAt = createdAt; self.updatedAt = updatedAt
    }

    // MARK: Freshness

    var daysUntilExpiry: Int? {
        guard let expiryDate else { return nil }
        let today = Calendar.current.startOfDay(for: .now)
        let expiry = Calendar.current.startOfDay(for: expiryDate)
        return Calendar.current.dateComponents([.day], from: today, to: expiry).day
    }

    var freshnessGrade: FreshnessGrade {
        guard let days = daysUntilExpiry else { return .unknown }
        switch days {
        case ..<0:   return .expired
        case 0...2:  return .urgent
        case 3...6:  return .useSoon
        case 7...13: return .good
        default:     return .fresh
        }
    }

    var isExpired: Bool { (daysUntilExpiry ?? 0) < 0 }
    var isUrgent: Bool  { (daysUntilExpiry ?? Int.max) <= 2 }

    var quantityDisplay: String {
        let q = quantity == floor(quantity)
            ? String(Int(quantity))
            : String(format: "%.1f", quantity)
        return "\(q) \(unit)"
    }
}

// MARK: - FreshnessGrade

enum FreshnessGrade: Sendable, Equatable {
    case fresh, good, useSoon, urgent, expired, unknown

    var badgeLabel: String {
        switch self {
        case .fresh:   return "FRESH"
        case .good:    return "GOOD"
        case .useSoon: return "USE SOON"
        case .urgent:  return "URGENT"
        case .expired: return "EXPIRED"
        case .unknown: return "NO DATE"
        }
    }

    var badgeBgColor: Color {
        switch self {
        case .fresh:   return Color.ftDeepForest.opacity(0.07)
        case .good:    return Color(hex: "EAB308").opacity(0.12)
        case .useSoon: return Color.ftBronze.opacity(0.12)
        case .urgent:  return Color.ftCrimson.opacity(0.12)
        case .expired: return Color.ftCrimson.opacity(0.15)
        case .unknown: return Color.ftSoftClay.opacity(0.2)
        }
    }

    var badgeLabelColor: Color {
        switch self {
        case .fresh:   return Color.ftDeepForest.opacity(0.45)
        case .good:    return Color(hex: "A07F08")
        case .useSoon: return Color.ftBronze
        case .urgent:  return Color.ftCrimson
        case .expired: return Color.ftCrimson
        case .unknown: return Color.ftDeepForest.opacity(0.3)
        }
    }
}

// MARK: - PantryItemInsert

/// Use String for date fields to guarantee "yyyy-MM-dd" encoding,
/// avoiding timezone-induced off-by-one errors with DATE columns.
struct PantryItemInsert: Encodable {
    let userId: UUID
    let name: String
    let brand: String?
    let barcode: String?
    let imageUrl: String?
    let category: ItemCategory
    let storageLocation: StorageLocation
    let addedVia: AddedVia
    let quantity: Double
    let unit: String
    let expiryDate: String?
    let purchaseDate: String?

    enum CodingKeys: String, CodingKey {
        case userId          = "user_id"
        case name, brand, barcode
        case imageUrl        = "image_url"
        case category
        case storageLocation = "storage_location"
        case addedVia        = "added_via"
        case quantity, unit
        case expiryDate      = "expiry_date"
        case purchaseDate    = "purchase_date"
    }

    static let isoDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func dateString(from date: Date?) -> String? {
        guard let date else { return nil }
        return isoDateFormatter.string(from: date)
    }
}

// MARK: - PantryItemUpdate

struct PantryItemUpdate: Encodable {
    let name: String
    let brand: String?
    let category: ItemCategory
    let storageLocation: StorageLocation
    let quantity: Double
    let unit: String
    let expiryDate: String?
    let notes: String?

    init(from item: PantryItem) {
        self.name = item.name
        self.brand = item.brand
        self.category = item.category
        self.storageLocation = item.storageLocation
        self.quantity = item.quantity
        self.unit = item.unit
        self.expiryDate = PantryItemInsert.dateString(from: item.expiryDate)
        self.notes = item.notes
    }

    enum CodingKeys: String, CodingKey {
        case name, brand, category
        case storageLocation = "storage_location"
        case quantity, unit
        case expiryDate = "expiry_date"
        case notes
    }
}

// MARK: - Preview Helpers

extension PantryItem {
    static var preview: PantryItem {
        PantryItem(
            id: UUID(), userId: UUID(),
            name: "Whole Milk", brand: "Organic Valley",
            barcode: nil, imageUrl: nil,
            category: .dairy, storageLocation: .fridge, addedVia: .barcode,
            quantity: 0.5, unit: "gallon",
            expiryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            purchaseDate: Date(), openedDate: nil, freshnessOverrideDays: nil,
            isConsumed: false, consumedAt: nil, notes: nil,
            createdAt: Date(), updatedAt: Date()
        )
    }
}
