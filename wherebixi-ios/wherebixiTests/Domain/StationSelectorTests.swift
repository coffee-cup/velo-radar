import CoreLocation
import XCTest
@testable import wherebixi

final class StationSelectorTests: XCTestCase {
    @MainActor
    func testClosestStationForAnyBikeChoosesNearestEligibleStation() throws {
        let userCoordinate = CLLocationCoordinate2D(latitude: 45.5000, longitude: -73.5700)
        let stations = [
            station(id: "nearest-inactive", latitude: 45.5001, longitude: -73.5700, classicBikes: 8, electricBikes: 0, isInstalled: false),
            station(id: "nearest-not-renting", latitude: 45.5002, longitude: -73.5700, classicBikes: 8, electricBikes: 0, isRenting: false),
            station(id: "nearest-insufficient", latitude: 45.5003, longitude: -73.5700, classicBikes: 1, electricBikes: 0),
            station(id: "closest-eligible", latitude: 45.5010, longitude: -73.5700, classicBikes: 2, electricBikes: 0),
            station(id: "farther-eligible", latitude: 45.5100, longitude: -73.5700, classicBikes: 5, electricBikes: 0)
        ]

        let match = try XCTUnwrap(
            StationSelector().closestStation(
                in: stations,
                from: userCoordinate,
                preferences: SearchPreferences(mode: .bikes, quantity: 2)
            )
        )

        XCTAssertEqual(match.station.id, "closest-eligible")
        XCTAssertGreaterThan(match.distanceMeters, 0)
        XCTAssertGreaterThanOrEqual(match.bearingDegrees, 0)
        XCTAssertLessThan(match.bearingDegrees, 360)
    }

    @MainActor
    func testClosestStationForElectricBikeRequiresEnoughEBikes() throws {
        let userCoordinate = CLLocationCoordinate2D(latitude: 45.5000, longitude: -73.5700)
        let stations = [
            station(id: "classic-only", latitude: 45.5001, longitude: -73.5700, classicBikes: 10, electricBikes: 0),
            station(id: "one-ebike", latitude: 45.5002, longitude: -73.5700, classicBikes: 10, electricBikes: 1),
            station(id: "enough-ebikes", latitude: 45.5100, longitude: -73.5700, classicBikes: 0, electricBikes: 2)
        ]

        let match = try XCTUnwrap(
            StationSelector().closestStation(
                in: stations,
                from: userCoordinate,
                preferences: SearchPreferences(mode: .bikes, quantity: 2, bikePreference: .electricRequired)
            )
        )

        XCTAssertEqual(match.station.id, "enough-ebikes")
    }

    @MainActor
    func testClosestStationForDocksRequiresReturningAndEnoughOpenDocks() throws {
        let userCoordinate = CLLocationCoordinate2D(latitude: 45.5000, longitude: -73.5700)
        let stations = [
            station(id: "not-returning", latitude: 45.5001, longitude: -73.5700, docks: 10, isReturning: false),
            station(id: "insufficient-docks", latitude: 45.5002, longitude: -73.5700, docks: 1),
            station(id: "closest-returning", latitude: 45.5010, longitude: -73.5700, docks: 2),
            station(id: "farther-returning", latitude: 45.5100, longitude: -73.5700, docks: 8)
        ]

        let match = try XCTUnwrap(
            StationSelector().closestStation(
                in: stations,
                from: userCoordinate,
                preferences: SearchPreferences(mode: .docks, quantity: 2)
            )
        )

        XCTAssertEqual(match.station.id, "closest-returning")
    }

    @MainActor
    func testReturnsNilWhenNoStationMatchesPreferences() {
        let match = StationSelector().closestStation(
            in: [station(id: "empty", classicBikes: 0, electricBikes: 0, docks: 0)],
            from: CLLocationCoordinate2D(latitude: 45.5000, longitude: -73.5700),
            preferences: SearchPreferences(mode: .bikes, quantity: 1)
        )

        XCTAssertNil(match)
    }
}

@MainActor
private func station(
    id: String,
    latitude: CLLocationDegrees = 45.5000,
    longitude: CLLocationDegrees = -73.5700,
    classicBikes: Int = 0,
    electricBikes: Int = 0,
    docks: Int = 0,
    isInstalled: Bool = true,
    isRenting: Bool = true,
    isReturning: Bool = true
) -> BixiStation {
    BixiStation(
        id: id,
        name: id,
        latitude: latitude,
        longitude: longitude,
        capacity: 20,
        classicBikesAvailable: classicBikes,
        electricBikesAvailable: electricBikes,
        docksAvailable: docks,
        isInstalled: isInstalled,
        isRenting: isRenting,
        isReturning: isReturning,
        statusLastReported: Date(timeIntervalSince1970: 1_700_000_000),
        feedLastUpdated: Date(timeIntervalSince1970: 1_700_000_010),
        feedTTL: 10
    )
}
