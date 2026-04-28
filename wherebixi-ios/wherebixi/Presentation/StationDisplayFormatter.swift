import CoreLocation
import Foundation

enum StationDisplayFormatter {
    static func distanceText(_ meters: CLLocationDistance) -> String {
        if meters < 1_000 {
            let roundedMeters = Int((meters / 10).rounded() * 10)
            return "\(max(10, roundedMeters)) m"
        }

        let kilometers = meters / 1_000
        return String(format: "%.1f km", kilometers)
    }

    static func cardinalDirectionText(for bearingDegrees: CLLocationDirection) -> String {
        let directions = [
            "north", "northeast", "east", "southeast",
            "south", "southwest", "west", "northwest"
        ]
        let index = Int(((bearingDegrees + 22.5).truncatingRemainder(dividingBy: 360)) / 45)
        return directions[index]
    }

    static func freshnessText(feedLastUpdated: Date, now: Date = Date()) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(feedLastUpdated)))

        switch seconds {
        case 0..<15:
            return "Updated just now"
        case 15..<60:
            return "Updated \(seconds)s ago"
        default:
            let minutes = max(1, seconds / 60)
            return "Updated \(minutes)m ago"
        }
    }

    static func availabilityText(for station: BixiStation, mode: SearchMode) -> String {
        switch mode {
        case .bikes:
            if station.electricBikesAvailable > 0 {
                return "\(station.totalBikesAvailable) bikes · \(station.electricBikesAvailable) e-bikes"
            }
            return "\(station.totalBikesAvailable) bikes available"
        case .docks:
            return "\(station.docksAvailable) docks available"
        }
    }
}
