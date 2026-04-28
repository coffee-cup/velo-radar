import Foundation

enum BixiAPIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Could not read the BIXI response. Try again."
        case .httpStatus:
            "Could not load BIXI stations. Try again."
        case .decodingFailed:
            "BIXI data changed unexpectedly. Try again later."
        }
    }
}

struct BixiAPIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchStationInformation() async throws -> GBFSResponse<StationInformationPayload> {
        try await fetch(BixiEndpoint.stationInformation)
    }

    func fetchStationStatus() async throws -> GBFSResponse<StationStatusPayload> {
        try await fetch(BixiEndpoint.stationStatus)
    }

    private func fetch<Response: Decodable>(_ url: URL) async throws -> Response {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BixiAPIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw BixiAPIError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw BixiAPIError.decodingFailed(error)
        }
    }
}

private enum BixiEndpoint {
    static let stationInformation = URL(string: "https://gbfs.velobixi.com/gbfs/2-2/en/station_information.json")!
    static let stationStatus = URL(string: "https://gbfs.velobixi.com/gbfs/2-2/en/station_status.json")!
}
