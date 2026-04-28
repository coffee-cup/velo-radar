import Combine
import CoreLocation
import Foundation

final class LocationService: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var headingDegrees: CLLocationDirection?
    @Published private(set) var locationError: String?

    private let manager: CLLocationManager

    override init() {
        manager = CLLocationManager()
        authorizationStatus = manager.authorizationStatus
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 10
        manager.headingFilter = 5
    }

    func startUpdatingIfAuthorized() {
        authorizationStatus = manager.authorizationStatus

        guard authorizationStatus.isAuthorizedForLocation else {
            manager.stopUpdatingLocation()
            manager.stopUpdatingHeading()
            return
        }

        locationError = nil
        manager.startUpdatingLocation()

        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }

    func requestWhenInUseAuthorization() {
        authorizationStatus = manager.authorizationStatus

        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            startUpdatingIfAuthorized()
        }
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        startUpdatingIfAuthorized()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        currentLocation = latestLocation
        locationError = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else { return }

        if newHeading.trueHeading >= 0 {
            headingDegrees = newHeading.trueHeading
        } else {
            headingDegrees = newHeading.magneticHeading
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = "Could not find your location. Try again."
    }
}

extension CLAuthorizationStatus {
    var isAuthorizedForLocation: Bool {
        self == .authorizedWhenInUse || self == .authorizedAlways
    }
}
