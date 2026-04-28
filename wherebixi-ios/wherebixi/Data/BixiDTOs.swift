import Foundation

struct GBFSResponse<Payload: Decodable>: Decodable {
    let lastUpdated: Int
    let ttl: Int
    let data: Payload

    enum CodingKeys: String, CodingKey {
        case lastUpdated = "last_updated"
        case ttl
        case data
    }

    var lastUpdatedDate: Date {
        Date(timeIntervalSince1970: TimeInterval(lastUpdated))
    }

    var ttlInterval: TimeInterval {
        TimeInterval(max(ttl, 0))
    }
}

struct StationInformationPayload: Decodable {
    let stations: [StationInformationDTO]
}

struct StationInformationDTO: Decodable {
    let stationID: String
    let name: String
    let latitude: Double
    let longitude: Double
    let capacity: Int

    enum CodingKeys: String, CodingKey {
        case stationID = "station_id"
        case name
        case latitude = "lat"
        case longitude = "lon"
        case capacity
    }
}

struct StationStatusPayload: Decodable {
    let stations: [StationStatusDTO]
}

struct StationStatusDTO: Decodable {
    let stationID: String
    let bikesAvailable: Int
    let electricBikesAvailable: Int
    let docksAvailable: Int
    let isInstalled: Int
    let isRenting: Int
    let isReturning: Int
    let lastReported: Int?

    enum CodingKeys: String, CodingKey {
        case stationID = "station_id"
        case bikesAvailable = "num_bikes_available"
        case electricBikesAvailable = "num_ebikes_available"
        case docksAvailable = "num_docks_available"
        case isInstalled = "is_installed"
        case isRenting = "is_renting"
        case isReturning = "is_returning"
        case lastReported = "last_reported"
    }

    var classicBikesAvailable: Int {
        max(0, bikesAvailable - electricBikesAvailable)
    }

    var lastReportedDate: Date? {
        guard let lastReported else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(lastReported))
    }
}
