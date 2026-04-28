import XCTest
@testable import wherebixi

final class SearchPreferencesTests: XCTestCase {
    @MainActor
    func testQuantityIsClampedToAtLeastOne() {
        XCTAssertEqual(SearchPreferences(mode: .bikes, quantity: 0).quantity, 1)
        XCTAssertEqual(SearchPreferences(mode: .docks, quantity: -3).quantity, 1)
        XCTAssertEqual(SearchPreferences(mode: .bikes, quantity: 4).quantity, 4)
    }

    @MainActor
    func testBixiStationTotalBikesIncludesClassicAndElectricBikes() {
        let station = BixiStation(
            id: "station",
            name: "Station",
            latitude: 45.5,
            longitude: -73.57,
            capacity: 20,
            classicBikesAvailable: 3,
            electricBikesAvailable: 2,
            docksAvailable: 4,
            isInstalled: true,
            isRenting: true,
            isReturning: true,
            statusLastReported: nil,
            feedLastUpdated: Date(timeIntervalSince1970: 1_700_000_000),
            feedTTL: 10
        )

        XCTAssertEqual(station.totalBikesAvailable, 5)
    }
}
