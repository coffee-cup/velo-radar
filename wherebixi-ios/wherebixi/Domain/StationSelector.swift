import CoreLocation
import Foundation

struct StationMatch {
    let station: BixiStation
    let distanceMeters: CLLocationDistance
    let bearingDegrees: CLLocationDirection
}

struct StationSelector {
    func closestStation(
        in stations: [BixiStation],
        from userCoordinate: CLLocationCoordinate2D,
        preferences: SearchPreferences
    ) -> StationMatch? {
        stations
            .filter { isEligible($0, for: preferences) }
            .map { station in
                StationMatch(
                    station: station,
                    distanceMeters: distance(from: userCoordinate, to: station.coordinate),
                    bearingDegrees: bearing(from: userCoordinate, to: station.coordinate)
                )
            }
            .min { $0.distanceMeters < $1.distanceMeters }
    }

    private func isEligible(_ station: BixiStation, for preferences: SearchPreferences) -> Bool {
        guard station.isInstalled else { return false }

        switch preferences.mode {
        case .bikes:
            guard station.isRenting else { return false }

            switch preferences.bikePreference {
            case .any:
                return station.totalBikesAvailable >= preferences.quantity
            case .electricRequired:
                return station.electricBikesAvailable >= preferences.quantity
            }

        case .docks:
            guard station.isReturning else { return false }
            return station.docksAvailable >= preferences.quantity
        }
    }

    private func distance(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) -> CLLocationDistance {
        CLLocation(latitude: origin.latitude, longitude: origin.longitude)
            .distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))
    }

    private func bearing(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) -> CLLocationDirection {
        let originLatitude = origin.latitude.degreesToRadians
        let destinationLatitude = destination.latitude.degreesToRadians
        let longitudeDelta = (destination.longitude - origin.longitude).degreesToRadians

        let y = sin(longitudeDelta) * cos(destinationLatitude)
        let x = cos(originLatitude) * sin(destinationLatitude)
            - sin(originLatitude) * cos(destinationLatitude) * cos(longitudeDelta)

        return atan2(y, x).radiansToDegrees.normalizedDegrees
    }
}

private extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
    var normalizedDegrees: Double {
        let value = truncatingRemainder(dividingBy: 360)
        return value >= 0 ? value : value + 360
    }
}
