# Architecture

WhereBixi is a small iOS SwiftUI app for answering two questions quickly:

1. Where is the closest BIXI station with enough bikes for me or my group?
2. Where is the closest BIXI station with enough open docks to return bikes?

The app avoids a map-first interaction. The primary interface is a simple directional view that points the user toward the best station and summarizes distance, street/station name, availability, and data freshness.

## Implemented

### User experience

- `ContentView` owns a `StationFinderViewModel` and presents the app inside a native SwiftUI `NavigationStack`.
- The start screen is `ModePickerView`, with two large full-width choice cards:
  - Find Bikes
  - Find Docks
- The finder screen is `StationFinderView`, with:
  - A large Find My-style directional arrow.
  - Distance and direction text.
  - Station name.
  - Bike or dock availability.
  - BIXI freshness/stale-data messaging.
  - A rider/dock count stepper supporting 1–9 bikes/docks, persisted locally across launches.
  - An "Any bike" vs "E-bike" segmented control for bike mode, persisted locally across launches.
  - Lightweight native theming with Liquid Glass cards/panels/buttons, Dynamic Type typography, red regular-bike accents, blue e-bike accents, and neutral dock accents.
  - Native back navigation, including the standard interactive swipe-back gesture.
  - A toolbar refresh control.
- SwiftUI previews include a ready finder preview with sample station, distance, direction, availability, and freshness data.
- Empty and error states are implemented for:
  - Location permission not requested.
  - Location permission denied/restricted.
  - Locating the user.
  - Loading BIXI data.
  - Network/API failure.
  - No matching station.

### App structure

The app is still a single iOS target and module under `wherebixi-ios/wherebixi/`, organized by responsibility:

- `Domain/`
  - `BixiStation`
  - `SearchMode`
  - `BikePreference`
  - `SearchPreferences`
  - `StationSelector`
- `Data/`
  - `BixiAPIClient`
  - GBFS DTOs
  - `StationRepository`
- `Location/`
  - `LocationService`
- `Presentation/`
  - display formatting helpers
  - lightweight theme tokens for colors, typography, Liquid Glass styling, and app background
- `Features/StationFinder/`
  - mode picker UI
  - finder UI
  - direction indicator UI
  - finder view model

### Data source

- BIXI data comes from the public GBFS v2.2 feeds documented in `docs/BIXI_API.md`.
- `BixiAPIClient` fetches:
  - `station_information`
  - `station_status`
- `StationRepository` joins those feeds by `station_id` into `BixiStation` models.
- Static station information is cached in memory for one hour.
- Live station status is cached in memory and is not refetched faster than the feed TTL or 10 seconds, whichever is larger.
- The finder refresh loop runs about every 15 seconds while a finder mode is open.

### Domain model

The app maintains a joined station model containing:

- Station id.
- Display name.
- Coordinates.
- Capacity.
- Available classic bikes.
- Available e-bikes.
- Available docks.
- Renting / returning / installed flags.
- Feed freshness metadata.

Classic bike count is derived from GBFS as:

```text
num_bikes_available - num_ebikes_available
```

### Selection logic

`StationSelector` is pure domain logic. It accepts:

- Current user location.
- Desired mode: find bikes or find docks.
- Number of bikes/docks needed.
- Bike preference for bike mode.

It filters inactive/unusable stations, filters by required availability, calculates straight-line distance from the user, calculates bearing, and returns the closest matching station.

Bike preference currently supports:

- Any bike.
- E-bike required.

### Location and heading

`LocationService` wraps Core Location for:

- When-in-use location authorization.
- Current location updates.
- Device heading updates when available.

Location permission is requested in context from the finder screen, not at app launch. If heading is unavailable, the finder falls back to showing cardinal direction text such as "northeast" instead of relying on a rotating arrow.

## Planned / next

- Add unit tests for `StationSelector` and feed joining.
- Add a more nuanced "prefer e-bike" mode that does not choose an unreasonable detour.
- Consider persisting the last selected mode.
- Consider an "Open in Maps" secondary action.
- Consider route distance instead of straight-line distance.
- Consider favorites or recently used stations.
- Consider station-level stale data using `last_reported`, not only feed-level freshness.

## Not planned yet

- Account login.
- Unlocking bikes.
- Payments.
- Trip history.
- Full map replacement.
- Backend service.
- Historical trip analytics.
