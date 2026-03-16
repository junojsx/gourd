import Foundation

/// Parsed parameters from a `freshtrack://cook-now` deep link.
struct CookNowFilter {
    /// Pre-selected expiry window (from `?window=` query param).
    var window: ExpiryWindow

    /// Specific item IDs to pre-select (from `?ids=uuid1,uuid2` query param).
    var preSelectedIds: Set<UUID>

    init(window: ExpiryWindow = .all, preSelectedIds: Set<UUID> = []) {
        self.window = window
        self.preSelectedIds = preSelectedIds
    }

    /// Initializes from URL query items, e.g. from `onOpenURL`.
    init(from queryItems: [URLQueryItem]?) {
        var window: ExpiryWindow = .all
        var ids: Set<UUID> = []

        for item in queryItems ?? [] {
            switch item.name {
            case "window":
                if let value = item.value,
                   let parsed = ExpiryWindow(rawValue: value) {
                    window = parsed
                }
            case "ids":
                if let value = item.value {
                    ids = Set(
                        value
                            .split(separator: ",")
                            .compactMap { UUID(uuidString: String($0)) }
                    )
                }
            default:
                break
            }
        }

        self.window = window
        self.preSelectedIds = ids
    }
}
