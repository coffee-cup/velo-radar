import CoreLocation
import Foundation

struct BixiStation: Identifiable, Equatable {
    let id: String
    let name: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let capacity: Int
    let classicBikesAvailable: Int
    let electricBikesAvailable: Int
    let docksAvailable: Int
    let isInstalled: Bool
    let isRenting: Bool
    let isReturning: Bool
    let statusLastReported: Date?
    let feedLastUpdated: Date
    let feedTTL: TimeInterval

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var totalBikesAvailable: Int {
        classicBikesAvailable + electricBikesAvailable
    }
}
