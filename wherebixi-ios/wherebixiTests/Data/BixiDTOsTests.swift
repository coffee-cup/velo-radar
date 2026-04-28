import XCTest
@testable import wherebixi

final class BixiDTOsTests: XCTestCase {
    @MainActor
    func testDecodesStationStatusAndDerivedFields() throws {
        let response = try JSONDecoder().decode(
            GBFSResponse<StationStatusPayload>.self,
            from: Data(Self.stationStatusJSON.utf8)
        )

        XCTAssertEqual(response.lastUpdatedDate, Date(timeIntervalSince1970: 1_700_000_100))
        XCTAssertEqual(response.ttlInterval, 10)
        XCTAssertEqual(response.data.stations.count, 2)

        let station = try XCTUnwrap(response.data.stations.first)
        XCTAssertEqual(station.stationID, "15")
        XCTAssertEqual(station.bikesAvailable, 8)
        XCTAssertEqual(station.electricBikesAvailable, 3)
        XCTAssertEqual(station.classicBikesAvailable, 5)
        XCTAssertEqual(station.docksAvailable, 12)
        XCTAssertEqual(station.isInstalled, 1)
        XCTAssertEqual(station.isRenting, 1)
        XCTAssertEqual(station.isReturning, 0)
        XCTAssertEqual(station.lastReportedDate, Date(timeIntervalSince1970: 1_700_000_090))

        let inconsistentStation = response.data.stations[1]
        XCTAssertEqual(inconsistentStation.classicBikesAvailable, 0)
        XCTAssertNil(inconsistentStation.lastReportedDate)
    }

    @MainActor
    func testDecodesStationInformation() throws {
        let response = try JSONDecoder().decode(
            GBFSResponse<StationInformationPayload>.self,
            from: Data(Self.stationInformationJSON.utf8)
        )

        XCTAssertEqual(response.ttlInterval, 3_600)

        let station = try XCTUnwrap(response.data.stations.first)
        XCTAssertEqual(station.stationID, "15")
        XCTAssertEqual(station.name, "Berri-UQAM / de Maisonneuve")
        XCTAssertEqual(station.latitude, 45.5153)
        XCTAssertEqual(station.longitude, -73.5610)
        XCTAssertEqual(station.capacity, 31)
    }

    @MainActor
    func testNegativeTTLIsClampedToZero() throws {
        let response = try JSONDecoder().decode(
            GBFSResponse<StationInformationPayload>.self,
            from: Data(Self.negativeTTLJSON.utf8)
        )

        XCTAssertEqual(response.ttlInterval, 0)
    }

    private static let stationStatusJSON = #"""
    {
      "last_updated": 1700000100,
      "ttl": 10,
      "data": {
        "stations": [
          {
            "station_id": "15",
            "num_bikes_available": 8,
            "num_ebikes_available": 3,
            "num_docks_available": 12,
            "is_installed": 1,
            "is_renting": 1,
            "is_returning": 0,
            "last_reported": 1700000090
          },
          {
            "station_id": "16",
            "num_bikes_available": 1,
            "num_ebikes_available": 3,
            "num_docks_available": 4,
            "is_installed": 1,
            "is_renting": 1,
            "is_returning": 1
          }
        ]
      }
    }
    """#

    private static let stationInformationJSON = #"""
    {
      "last_updated": 1700000000,
      "ttl": 3600,
      "data": {
        "stations": [
          {
            "station_id": "15",
            "name": "Berri-UQAM / de Maisonneuve",
            "lat": 45.5153,
            "lon": -73.5610,
            "capacity": 31
          }
        ]
      }
    }
    """#

    private static let negativeTTLJSON = #"""
    {
      "last_updated": 1700000000,
      "ttl": -5,
      "data": {
        "stations": []
      }
    }
    """#
}
