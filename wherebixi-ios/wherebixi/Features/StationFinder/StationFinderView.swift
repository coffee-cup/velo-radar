import SwiftUI
import UIKit

struct StationFinderView: View {
    @ObservedObject var viewModel: StationFinderViewModel
    @Environment(\.openURL) private var openURL

    private var mode: SearchMode {
        viewModel.selectedMode ?? .bikes
    }

    private var accentColor: Color {
        AppTheme.Colors.accent(for: mode, bikePreference: viewModel.bikePreference)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            content
                .frame(maxWidth: .infinity)

            Spacer(minLength: 16)

            preferencesPanel
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { AppBackground() }
        .tint(accentColor)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.refreshNow()
                } label: {
                    if viewModel.isRefreshing {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(viewModel.isRefreshing)
                .accessibilityLabel("Refresh")
                .accessibilityHint("Reloads live BIXI availability")
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.contentState {
        case .idle:
            EmptyView()
        case .needsLocationPermission:
            locationPermissionView
        case .locationDenied:
            locationDeniedView
        case .locating:
            LoadingStateView(
                title: "Finding you",
                message: "We’ll point you toward the closest matching station."
            )
        case .loadingStations:
            LoadingStateView(
                title: "Loading BIXI availability",
                message: "Checking live station data."
            )
        case .ready(let match):
            DirectionResultView(
                match: match,
                distanceText: viewModel.distanceText(for: match),
                directionText: viewModel.directionText(for: match),
                availabilityText: viewModel.availabilityText(for: match.station),
                freshnessText: viewModel.freshnessText,
                isStale: viewModel.isDataStale,
                headingDegrees: viewModel.headingDegrees,
                mode: mode,
                accentColor: accentColor
            )
        case .noMatch:
            noMatchView
        case .failed(let message):
            failureView(message: message)
        }
    }

    private var locationPermissionView: some View {
        ContentUnavailableView {
            Label("Use Your Location", systemImage: "location.fill")
        } description: {
            Text("WhereBixi uses your location to point you toward the closest station. Your location stays on this device.")
                .padding(.top, 8)
        } actions: {
            Button("Use My Location") {
                viewModel.requestLocationPermission()
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }

    private var locationDeniedView: some View {
        ContentUnavailableView {
            Label("Location Is Off", systemImage: "location.slash")
        } description: {
            Text("Turn on location access in Settings so WhereBixi can find the closest station.")
        } actions: {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    openURL(settingsURL)
                }
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }

    private var noMatchView: some View {
        ContentUnavailableView {
            Label("No Station Found", systemImage: "magnifyingglass")
        } description: {
            Text("Try fewer \(mode == .bikes ? "riders" : "docks") or go back and switch modes.")
        } actions: {
            Button("Refresh") {
                viewModel.refreshNow()
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }

    private func failureView(message: String) -> some View {
        ContentUnavailableView {
            Label("Couldn’t Load Stations", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                viewModel.retry()
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }

    private var preferencesPanel: some View {
        VStack(spacing: 16) {
            Stepper(value: $viewModel.requestedQuantity, in: 1...6) {
                HStack(spacing: 12) {
                    Image(systemName: mode == .bikes ? "person.2.fill" : "arrow.down.circle.fill")
                        .foregroundStyle(accentColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(mode.quantityLabel)
                            .font(.headline)

                        Text(mode == .bikes ? "How many bikes to find" : "How many open docks to find")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(viewModel.requestedQuantity)")
                        .font(.headline)
                        .foregroundStyle(accentColor)
                        .monospacedDigit()
                }
            }
            .controlSize(.large)

            if mode == .bikes {
                Picker("Bike type", selection: $viewModel.bikePreference) {
                    ForEach(BikePreference.allCases) { preference in
                        Text(preference.title).tag(preference)
                    }
                }
                .pickerStyle(.segmented)
                .tint(accentColor)
            }
        }
        .padding(18)
        .glassEffect(
            AppTheme.glass(tint: accentColor.opacity(0.16)),
            in: .rect(cornerRadius: AppTheme.CornerRadius.panel, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.panel, style: .continuous)
                .stroke(AppTheme.Colors.glassStroke, lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }
}

private struct DirectionResultView: View {
    let match: StationMatch
    let distanceText: String
    let directionText: String
    let availabilityText: String
    let freshnessText: String?
    let isStale: Bool
    let headingDegrees: Double?
    let mode: SearchMode
    let accentColor: Color

    var body: some View {
        VStack(spacing: 20) {
            DirectionIndicatorView(
                bearingDegrees: match.bearingDegrees,
                headingDegrees: headingDegrees,
                accentColor: accentColor
            )

            VStack(spacing: 4) {
                Text(distanceText)
                    .font(AppTheme.Typography.heroDistance)
                    .monospacedDigit()

                Text(directionText)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                Text(match.station.name)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)

                AvailabilityBadges(station: match.station, mode: mode)
            }

            VStack(spacing: 6) {
                if isStale {
                    Label("BIXI data may be stale", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }

                if let freshnessText {
                    Text(freshnessText)
                        .foregroundStyle(.secondary)
                }
            }
            .font(.footnote)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(distanceText) \(directionText). \(match.station.name). \(availabilityText).")
    }
}

private struct AvailabilityBadges: View {
    let station: BixiStation
    let mode: SearchMode

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                badgeContent
            }

            VStack(spacing: 10) {
                badgeContent
            }
        }
    }

    @ViewBuilder
    private var badgeContent: some View {
        switch mode {
        case .bikes:
            if station.classicBikesAvailable > 0 {
                AvailabilityBadge(
                    count: station.classicBikesAvailable,
                    singular: "regular bike",
                    plural: "regular bikes",
                    systemImageName: "bicycle",
                    color: AppTheme.Colors.regularBike
                )
            }

            if station.electricBikesAvailable > 0 {
                AvailabilityBadge(
                    count: station.electricBikesAvailable,
                    singular: "e-bike",
                    plural: "e-bikes",
                    systemImageName: "bolt.fill",
                    color: AppTheme.Colors.electricBike
                )
            }
        case .docks:
            AvailabilityBadge(
                count: station.docksAvailable,
                singular: "dock",
                plural: "docks",
                systemImageName: "arrow.down.circle.fill",
                color: AppTheme.Colors.dock
            )
        }
    }
}

private struct AvailabilityBadge: View {
    let count: Int
    let singular: String
    let plural: String
    let systemImageName: String
    let color: Color

    private var label: String {
        count == 1 ? singular : plural
    }

    var body: some View {
        Label {
            Text("\(count) \(label)")
                .foregroundStyle(.primary)
                .monospacedDigit()
        } icon: {
            Image(systemName: systemImageName)
                .foregroundStyle(color)
        }
        .font(.headline)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassEffect(
            AppTheme.glass(tint: color.opacity(0.18)),
            in: Capsule()
        )
        .overlay {
            Capsule()
                .stroke(color.opacity(0.22), lineWidth: 1)
        }
    }
}

private struct LoadingStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 18) {
            ProgressView()
                .controlSize(.large)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#if DEBUG
#Preview("Finder") {
    StationFinderView(viewModel: .previewReady())
}
#endif
