import Combine
import CoreLocation
import Foundation

enum FinderContentState {
    case idle
    case needsLocationPermission
    case locationDenied
    case locating
    case loadingStations
    case ready(StationMatch)
    case noMatch
    case failed(String)
}

@MainActor
final class StationFinderViewModel: ObservableObject {
    @Published private(set) var selectedMode: SearchMode?
    @Published private(set) var contentState: FinderContentState = .idle
    @Published private(set) var isRefreshing = false
    @Published private(set) var headingDegrees: CLLocationDirection?

    @Published var requestedQuantity = 1 {
        didSet { rebuildContentState() }
    }

    @Published var bikePreference: BikePreference = .any {
        didSet { rebuildContentState() }
    }

    private let repository: StationRepository
    private let locationService: LocationService
    private let selector: StationSelector
    private var stationSnapshot: StationSnapshot?
    private var currentLocation: CLLocation?
    private var authorizationStatus: CLAuthorizationStatus
    private var locationErrorMessage: String?
    private var loadErrorMessage: String?
    private var refreshTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    convenience init() {
        self.init(
            repository: StationRepository(),
            locationService: LocationService(),
            selector: StationSelector()
        )
    }

    init(
        repository: StationRepository,
        locationService: LocationService,
        selector: StationSelector
    ) {
        self.repository = repository
        self.locationService = locationService
        self.selector = selector
        authorizationStatus = locationService.authorizationStatus

        bindLocationService()
    }

    deinit {
        refreshTask?.cancel()
    }

    func selectMode(_ mode: SearchMode) {
        selectedMode = mode
        locationService.startUpdatingIfAuthorized()
        startRefreshLoop()
        rebuildContentState()
    }

    func returnToModePicker() {
        selectedMode = nil
        refreshTask?.cancel()
        refreshTask = nil
        locationService.stopUpdating()
        rebuildContentState()
    }

    func requestLocationPermission() {
        locationService.requestWhenInUseAuthorization()
        rebuildContentState()
    }

    func retry() {
        locationService.startUpdatingIfAuthorized()

        Task {
            await refreshStations()
        }
    }

    func refreshNow() {
        Task {
            await refreshStations()
        }
    }

    var freshnessText: String? {
        guard let stationSnapshot else { return nil }
        return StationDisplayFormatter.freshnessText(feedLastUpdated: stationSnapshot.feedLastUpdated)
    }

    var isDataStale: Bool {
        stationSnapshot?.isStale ?? false
    }

    func distanceText(for match: StationMatch) -> String {
        StationDisplayFormatter.distanceText(match.distanceMeters)
    }

    func directionText(for match: StationMatch) -> String {
        if headingDegrees != nil {
            return "this way"
        }

        return StationDisplayFormatter.cardinalDirectionText(for: match.bearingDegrees)
    }

    func availabilityText(for station: BixiStation) -> String {
        guard let selectedMode else { return "" }
        return StationDisplayFormatter.availabilityText(for: station, mode: selectedMode)
    }

    private func bindLocationService() {
        locationService.$authorizationStatus
            .sink { [weak self] status in
                guard let self else { return }
                authorizationStatus = status
                rebuildContentState()
            }
            .store(in: &cancellables)

        locationService.$currentLocation
            .sink { [weak self] location in
                guard let self else { return }
                currentLocation = location
                rebuildContentState()
            }
            .store(in: &cancellables)

        locationService.$headingDegrees
            .sink { [weak self] headingDegrees in
                guard let self else { return }
                self.headingDegrees = headingDegrees
            }
            .store(in: &cancellables)

        locationService.$locationError
            .sink { [weak self] errorMessage in
                guard let self else { return }
                locationErrorMessage = errorMessage
                rebuildContentState()
            }
            .store(in: &cancellables)
    }

    private func startRefreshLoop() {
        guard refreshTask == nil else { return }

        refreshTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refreshStations()
                try? await Task.sleep(nanoseconds: 15_000_000_000)
            }
        }
    }

    private func refreshStations() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        loadErrorMessage = nil
        rebuildContentState()

        do {
            stationSnapshot = try await repository.loadStations()
        } catch {
            loadErrorMessage = userMessage(for: error)
        }

        isRefreshing = false
        rebuildContentState()
    }

    private func rebuildContentState() {
        guard let selectedMode else {
            contentState = .idle
            return
        }

        switch authorizationStatus {
        case .notDetermined:
            contentState = .needsLocationPermission
            return
        case .denied, .restricted:
            contentState = .locationDenied
            return
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            contentState = .needsLocationPermission
            return
        }

        guard let currentLocation else {
            if let locationErrorMessage {
                contentState = .failed(locationErrorMessage)
            } else {
                contentState = .locating
            }
            return
        }

        guard let stationSnapshot else {
            if let loadErrorMessage {
                contentState = .failed(loadErrorMessage)
            } else {
                contentState = .loadingStations
            }
            return
        }

        let preferences = SearchPreferences(
            mode: selectedMode,
            quantity: requestedQuantity,
            bikePreference: selectedMode == .bikes ? bikePreference : .any
        )

        if let match = selector.closestStation(
            in: stationSnapshot.stations,
            from: currentLocation.coordinate,
            preferences: preferences
        ) {
            contentState = .ready(match)
        } else {
            contentState = .noMatch
        }
    }

    private func userMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "Could not load BIXI stations. Check your connection and try again."
            default:
                break
            }
        }

        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }

        return "Could not load BIXI stations. Try again."
    }
}
