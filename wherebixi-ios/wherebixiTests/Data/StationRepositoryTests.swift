import Foundation
import XCTest
@testable import wherebixi

final class StationRepositoryTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    @MainActor
    func testLoadStationsJoinsInformationAndStatusByStationID() async throws {
        let repository = makeRepository { request in
            if request.url?.absoluteString.contains("station_information") == true {
                return (200, Data(Self.stationInformationJSON.utf8))
            }

            if request.url?.absoluteString.contains("station_status") == true {
                return (200, Data(Self.stationStatusJSON.utf8))
            }

            return (404, Data())
        }

        let snapshot = try await repository.loadStations()

        XCTAssertEqual(snapshot.feedLastUpdated, Date(timeIntervalSince1970: 1_700_000_100))
        XCTAssertEqual(snapshot.feedTTL, 10)
        XCTAssertEqual(snapshot.stations.map(\.id), ["15"])

        let station = try XCTUnwrap(snapshot.stations.first)
        XCTAssertEqual(station.name, "Berri-UQAM / de Maisonneuve")
        XCTAssertEqual(station.latitude, 45.5153)
        XCTAssertEqual(station.longitude, -73.5610)
        XCTAssertEqual(station.capacity, 31)
        XCTAssertEqual(station.classicBikesAvailable, 5)
        XCTAssertEqual(station.electricBikesAvailable, 3)
        XCTAssertEqual(station.docksAvailable, 12)
        XCTAssertTrue(station.isInstalled)
        XCTAssertTrue(station.isRenting)
        XCTAssertFalse(station.isReturning)
        XCTAssertEqual(station.statusLastReported, Date(timeIntervalSince1970: 1_700_000_090))
        XCTAssertEqual(station.feedLastUpdated, Date(timeIntervalSince1970: 1_700_000_100))
        XCTAssertEqual(station.feedTTL, 10)
    }

    @MainActor
    func testLoadStationsUsesCachedInformationAndStatusInsideRefreshInterval() async throws {
        let requestLog = RequestLog()
        let repository = makeRepository { request in
            requestLog.record(request)

            if request.url?.absoluteString.contains("station_information") == true {
                return (200, Data(Self.stationInformationJSON.utf8))
            }

            if request.url?.absoluteString.contains("station_status") == true {
                return (200, Data(Self.stationStatusJSON.utf8))
            }

            return (404, Data())
        }

        let firstSnapshot = try await repository.loadStations()
        let secondSnapshot = try await repository.loadStations()

        XCTAssertEqual(firstSnapshot.fetchedAt, secondSnapshot.fetchedAt)
        XCTAssertEqual(requestLog.count(containing: "station_information"), 1)
        XCTAssertEqual(requestLog.count(containing: "station_status"), 1)
    }

    @MainActor
    private func makeRepository(
        requestHandler: @escaping (URLRequest) throws -> (Int, Data)
    ) -> StationRepository {
        MockURLProtocol.requestHandler = requestHandler

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let client = BixiAPIClient(session: session)

        return StationRepository(
            client: client,
            stationInformationCacheDuration: 3_600,
            minimumStatusRefreshInterval: 10
        )
    }

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
          },
          {
            "station_id": "16",
            "name": "Status missing",
            "lat": 45.5000,
            "lon": -73.5700,
            "capacity": 15
          }
        ]
      }
    }
    """#

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
            "station_id": "missing-information",
            "num_bikes_available": 6,
            "num_ebikes_available": 0,
            "num_docks_available": 9,
            "is_installed": 1,
            "is_renting": 1,
            "is_returning": 1,
            "last_reported": 1700000090
          }
        ]
      }
    }
    """#
}

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (Int, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let requestHandler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (statusCode, data) = try requestHandler(request)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private final class RequestLog {
    private let lock = NSLock()
    private var urls: [String] = []

    func record(_ request: URLRequest) {
        lock.lock()
        defer { lock.unlock() }

        urls.append(request.url?.absoluteString ?? "")
    }

    func count(containing fragment: String) -> Int {
        lock.lock()
        defer { lock.unlock() }

        return urls.filter { $0.contains(fragment) }.count
    }
}
