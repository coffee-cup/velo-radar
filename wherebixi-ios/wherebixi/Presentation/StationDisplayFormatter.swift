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
            let regularText = pluralized(station.classicBikesAvailable, singular: "regular bike", plural: "regular bikes")
            let electricText = pluralized(station.electricBikesAvailable, singular: "e-bike", plural: "e-bikes")

            switch (station.classicBikesAvailable > 0, station.electricBikesAvailable > 0) {
            case (true, true):
                return "\(regularText), \(electricText) available"
            case (true, false):
                return "\(regularText) available"
            case (false, true), (false, false):
                return "\(electricText) available"
            }
        case .docks:
            return "\(pluralized(station.docksAvailable, singular: "dock", plural: "docks")) available"
        }
    }

    private static func pluralized(_ count: Int, singular: String, plural: String) -> String {
        "\(count) \(count == 1 ? singular : plural)"
    }
}
