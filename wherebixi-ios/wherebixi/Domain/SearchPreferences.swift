import Foundation

/// The primary task the user wants WhereBixi to solve.
enum SearchMode: String, CaseIterable, Identifiable {
    case bikes
    case docks

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bikes:
            "Find Bikes"
        case .docks:
            "Find Docks"
        }
    }

    var shortTitle: String {
        switch self {
        case .bikes:
            "Bikes"
        case .docks:
            "Docks"
        }
    }

    var subtitle: String {
        switch self {
        case .bikes:
            "Closest station with ready bikes"
        case .docks:
            "Closest station with room to return"
        }
    }

    var systemImageName: String {
        switch self {
        case .bikes:
            "bicycle"
        case .docks:
            "arrow.down.circle.fill"
        }
    }

    var quantityLabel: String {
        switch self {
        case .bikes:
            "Riders"
        case .docks:
            "Docks needed"
        }
    }
}

enum BikePreference: String, CaseIterable, Identifiable {
    case any
    case electricRequired

    var id: String { rawValue }

    var title: String {
        switch self {
        case .any:
            "Any bike"
        case .electricRequired:
            "E-bike"
        }
    }
}

struct SearchPreferences {
    static let quantityRange = 1...9

    let mode: SearchMode
    let quantity: Int
    let bikePreference: BikePreference

    init(mode: SearchMode, quantity: Int, bikePreference: BikePreference = .any) {
        self.mode = mode
        self.quantity = Self.clampedQuantity(quantity)
        self.bikePreference = bikePreference
    }

    static func clampedQuantity(_ quantity: Int) -> Int {
        min(max(quantity, quantityRange.lowerBound), quantityRange.upperBound)
    }
}
