import SwiftUI
import UIKit

struct StationFinderView: View {
    @ObservedObject var viewModel: StationFinderViewModel
    @Environment(\.openURL) private var openURL

    private var mode: SearchMode {
        viewModel.selectedMode ?? .bikes
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
        .background(.background)
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
                headingDegrees: viewModel.headingDegrees
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
        } actions: {
            Button("Use My Location") {
                viewModel.requestLocationPermission()
            }
            .buttonStyle(.borderedProminent)
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
            .buttonStyle(.borderedProminent)
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
            .buttonStyle(.borderedProminent)
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
            .buttonStyle(.borderedProminent)
        }
    }

    private var preferencesPanel: some View {
        VStack(spacing: 16) {
            Stepper(value: $viewModel.requestedQuantity, in: 1...6) {
                HStack {
                    Text(mode.quantityLabel)
                    Spacer()
                    Text("\(viewModel.requestedQuantity)")
                        .font(.headline)
                        .monospacedDigit()
                }
            }

            if mode == .bikes {
                Picker("Bike type", selection: $viewModel.bikePreference) {
                    ForEach(BikePreference.allCases) { preference in
                        Text(preference.title).tag(preference)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(18)
        .background(.thinMaterial, in: .rect(cornerRadius: 24, style: .continuous))
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

    var body: some View {
        VStack(spacing: 20) {
            DirectionIndicatorView(
                bearingDegrees: match.bearingDegrees,
                headingDegrees: headingDegrees
            )

            VStack(spacing: 4) {
                Text(distanceText)
                    .font(.largeTitle.bold())
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

                Text(availabilityText)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
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

#Preview("Finder") {
    StationFinderView(viewModel: StationFinderViewModel())
}
