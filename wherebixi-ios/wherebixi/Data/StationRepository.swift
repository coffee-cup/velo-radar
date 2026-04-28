import Foundation

struct StationSnapshot {
    let stations: [BixiStation]
    let fetchedAt: Date
    let feedLastUpdated: Date
    let feedTTL: TimeInterval

    var isStale: Bool {
        Date().timeIntervalSince(feedLastUpdated) > max(60, feedTTL * 3)
    }
}

final class StationRepository {
    private let client: BixiAPIClient
    private let stationInformationCacheDuration: TimeInterval
    private let minimumStatusRefreshInterval: TimeInterval

    private var stationInformation: GBFSResponse<StationInformationPayload>?
    private var stationInformationFetchedAt: Date?
    private var stationSnapshot: StationSnapshot?

    init(
        client: BixiAPIClient = BixiAPIClient(),
        stationInformationCacheDuration: TimeInterval = 60 * 60,
        minimumStatusRefreshInterval: TimeInterval = 10
    ) {
        self.client = client
        self.stationInformationCacheDuration = stationInformationCacheDuration
        self.minimumStatusRefreshInterval = minimumStatusRefreshInterval
    }

    func loadStations() async throws -> StationSnapshot {
        let now = Date()
        let information = try await loadStationInformationIfNeeded(now: now)

        if let stationSnapshot,
           now.timeIntervalSince(stationSnapshot.fetchedAt) < max(stationSnapshot.feedTTL, minimumStatusRefreshInterval) {
            return stationSnapshot
        }

        let status = try await client.fetchStationStatus()
        let snapshot = join(information: information, status: status, fetchedAt: now)
        stationSnapshot = snapshot
        return snapshot
    }

    private func loadStationInformationIfNeeded(
        now: Date
    ) async throws -> GBFSResponse<StationInformationPayload> {
        if let stationInformation,
           let stationInformationFetchedAt,
           now.timeIntervalSince(stationInformationFetchedAt) < stationInformationCacheDuration {
            return stationInformation
        }

        let information = try await client.fetchStationInformation()
        stationInformation = information
        stationInformationFetchedAt = now
        return information
    }

    private func join(
        information: GBFSResponse<StationInformationPayload>,
        status: GBFSResponse<StationStatusPayload>,
        fetchedAt: Date
    ) -> StationSnapshot {
        let informationByID = Dictionary(
            uniqueKeysWithValues: information.data.stations.map { ($0.stationID, $0) }
        )

        let stations = status.data.stations.compactMap { statusStation -> BixiStation? in
            guard let informationStation = informationByID[statusStation.stationID] else {
                return nil
            }

            return BixiStation(
                id: statusStation.stationID,
                name: informationStation.name,
                latitude: informationStation.latitude,
                longitude: informationStation.longitude,
                capacity: informationStation.capacity,
                classicBikesAvailable: statusStation.classicBikesAvailable,
                electricBikesAvailable: statusStation.electricBikesAvailable,
                docksAvailable: statusStation.docksAvailable,
                isInstalled: statusStation.isInstalled == 1,
                isRenting: statusStation.isRenting == 1,
                isReturning: statusStation.isReturning == 1,
                statusLastReported: statusStation.lastReportedDate,
                feedLastUpdated: status.lastUpdatedDate,
                feedTTL: status.ttlInterval
            )
        }

        return StationSnapshot(
            stations: stations,
            fetchedAt: fetchedAt,
            feedLastUpdated: status.lastUpdatedDate,
            feedTTL: status.ttlInterval
        )
    }
}
