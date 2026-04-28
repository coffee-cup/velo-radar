# Architecture

WhereBixi is planned as a small iOS SwiftUI app for answering two questions quickly:

1. Where is the closest BIXI station with enough bikes for me or my group?
2. Where is the closest BIXI station with enough open docks to return bikes?

The app should avoid a map-first interaction. The primary interface is a simple directional compass-style view that points the user toward the best station and summarizes distance, street/station name, and availability.

## Implemented

- Minimal SwiftUI iOS app shell in `wherebixi-ios/`.
- `ContentView` currently renders the default placeholder UI.
- BIXI GBFS API notes are documented in `docs/BIXI_API.md`.

## Planned user experience

### Find bikes

Users configure:

- Number of riders / bikes needed.
- Whether electric bikes are required or preferred.

The app uses the user's current location and heading to find the closest station matching those preferences. The main UI should show a large directional arrow and a concise message such as:

> Closest bikes: 1 km this way at Saint-Urbain / Rachel.

The app should optimize for quick use while walking, not detailed station browsing.

### Find docks

Users switch to a return mode while riding. The app finds the closest station with enough open docks for the group and shows the same simple direction-first interface.

This mode should be especially glanceable because the user may be moving. It should avoid dense UI, tiny controls, and interactions that require prolonged attention.

## Planned technical architecture

### App shell

- SwiftUI app entry point in `wherebixi-ios/wherebixi/wherebixiApp.swift`.
- SwiftUI screens and components under `wherebixi-ios/wherebixi/`.
- The initial app can stay single-target and single-module until the codebase needs more structure.

### Data source

- BIXI data comes from the public GBFS v2.2 feeds documented in `docs/BIXI_API.md`.
- `station_information` provides mostly static station metadata: names, coordinates, and capacity.
- `station_status` provides live bike and dock counts.
- Static station information should be cached longer than live station status.
- Live station status should respect the feed TTL and should not poll faster than the documented refresh cadence.

### Domain model

The app should maintain a joined station model containing:

- Station id.
- Display name / street name.
- Coordinates.
- Capacity.
- Available classic bikes.
- Available e-bikes.
- Available docks.
- Renting / returning availability flags.
- Freshness metadata.

Classic bike count should be derived from GBFS as:

```text
num_bikes_available - num_ebikes_available
```

### Selection logic

The station selector should accept:

- Current user location.
- Desired mode: find bikes or find docks.
- Number of bikes/docks needed.
- E-bike preference.

It should filter unusable stations, filter by required availability, calculate distance from the user, and choose the closest matching station.

Future versions may account for heading, route distance, stale data, disabled stations, or user favorites, but the first version should use simple geographic distance.

### Location and heading

The app will need Core Location for:

- Current location.
- Device heading when available.
- Permission handling.

The compass UI should degrade gracefully if heading is unavailable by showing distance and station direction relative to the last known location.

### UI

The main UI should be intentionally simple:

- Mode toggle: find bikes / find docks.
- Minimal preference controls.
- Large arrow or compass indicator.
- Distance and station name.
- Availability summary.
- Freshness/error state when live data is unavailable or stale.

### Error handling

The app should handle:

- Location permission denied or unavailable.
- Network failures.
- Stale GBFS data.
- No matching station found.
- BIXI seasonal shutdown or zeroed feeds.

## Not planned yet

- Account login.
- Unlocking bikes.
- Payments.
- Trip history.
- Full map replacement.
- Backend service.
- Historical trip analytics.
