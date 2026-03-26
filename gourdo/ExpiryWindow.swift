import Foundation

enum ExpiryWindow: String, CaseIterable, Identifiable {
    case sameDay  = "0day"
    case oneDay   = "1day"
    case threeDay = "3day"
    case all

    var id: String { rawValue }

    var maxDays: Int? {
        switch self {
        case .sameDay:  return 0
        case .oneDay:   return 1
        case .threeDay: return 3
        case .all:      return nil
        }
    }

    var displayLabel: String {
        switch self {
        case .sameDay:  return "Today"
        case .oneDay:   return "1 Day"
        case .threeDay: return "3 Days"
        case .all:      return "All"
        }
    }

    /// Returns true if the given daysUntilExpiry falls within this window.
    func contains(daysUntilExpiry days: Int) -> Bool {
        guard let max = maxDays else { return true }
        return days >= 0 && days <= max
    }
}
