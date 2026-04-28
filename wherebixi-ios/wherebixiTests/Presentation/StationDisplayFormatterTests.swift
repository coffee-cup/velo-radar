import XCTest
@testable import wherebixi

final class StationDisplayFormatterTests: XCTestCase {
    @MainActor
    func testDistanceTextRoundsMetersAndKilometers() {
        XCTAssertEqual(StationDisplayFormatter.distanceText(4), "10 m")
        XCTAssertEqual(StationDisplayFormatter.distanceText(424), "420 m")
        XCTAssertEqual(StationDisplayFormatter.distanceText(1_250), "1.2 km")
    }

    @MainActor
    func testCardinalDirectionTextUsesEightDirections() {
        XCTAssertEqual(StationDisplayFormatter.cardinalDirectionText(for: 0), "north")
        XCTAssertEqual(StationDisplayFormatter.cardinalDirectionText(for: 45), "northeast")
        XCTAssertEqual(StationDisplayFormatter.cardinalDirectionText(for: 90), "east")
        XCTAssertEqual(StationDisplayFormatter.cardinalDirectionText(for: 180), "south")
        XCTAssertEqual(StationDisplayFormatter.cardinalDirectionText(for: 315), "northwest")
        XCTAssertEqual(StationDisplayFormatter.cardinalDirectionText(for: 359), "north")
    }

    @MainActor
    func testFreshnessText() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        XCTAssertEqual(
            StationDisplayFormatter.freshnessText(feedLastUpdated: now.addingTimeInterval(-14), now: now),
            "Updated just now"
        )
        XCTAssertEqual(
            StationDisplayFormatter.freshnessText(feedLastUpdated: now.addingTimeInterval(-42), now: now),
            "Updated 42s ago"
        )
        XCTAssertEqual(
            StationDisplayFormatter.freshnessText(feedLastUpdated: now.addingTimeInterval(-125), now: now),
            "Updated 2m ago"
        )
    }

    @MainActor
    func testAvailabilityTextForBikes() {
        XCTAssertEqual(
            StationDisplayFormatter.availabilityText(
                for: station(classicBikes: 2, electricBikes: 1),
                mode: .bikes
            ),
            "2 regular bikes, 1 e-bike available"
        )
        XCTAssertEqual(
            StationDisplayFormatter.availabilityText(
                for: station(classicBikes: 1, electricBikes: 0),
                mode: .bikes
            ),
            "1 regular bike available"
        )
        XCTAssertEqual(
            StationDisplayFormatter.availabilityText(
                for: station(classicBikes: 0, electricBikes: 2),
                mode: .bikes
            ),
            "2 e-bikes available"
        )
    }

    @MainActor
    func testAvailabilityTextForDocks() {
        XCTAssertEqual(
            StationDisplayFormatter.availabilityText(for: station(docks: 1), mode: .docks),
            "1 dock available"
        )
        XCTAssertEqual(
            StationDisplayFormatter.availabilityText(for: station(docks: 3), mode: .docks),
            "3 docks available"
        )
    }
}

@MainActor
private func station(
    classicBikes: Int = 0,
    electricBikes: Int = 0,
    docks: Int = 0
) -> BixiStation {
    BixiStation(
        id: "station",
        name: "Station",
        latitude: 45.5,
        longitude: -73.57,
        capacity: 20,
        classicBikesAvailable: classicBikes,
        electricBikesAvailable: electricBikes,
        docksAvailable: docks,
        isInstalled: true,
        isRenting: true,
        isReturning: true,
        statusLastReported: nil,
        feedLastUpdated: Date(timeIntervalSince1970: 1_700_000_000),
        feedTTL: 10
    )
}
