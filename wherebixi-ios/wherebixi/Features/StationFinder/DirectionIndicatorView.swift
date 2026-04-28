import CoreLocation
import SwiftUI

struct DirectionIndicatorView: View {
    let bearingDegrees: CLLocationDirection
    let headingDegrees: CLLocationDirection?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var indicatorSize: CGFloat = 220
    @State private var displayedRotationDegrees: Double?

    private var targetRotationDegrees: Double {
        guard let headingDegrees else { return 0 }
        return (bearingDegrees - headingDegrees).normalizedDegrees
    }

    private var currentRotationDegrees: Double {
        displayedRotationDegrees ?? targetRotationDegrees
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(.tint.opacity(0.12))

            Circle()
                .stroke(.tint.opacity(0.24), lineWidth: 1)

            Image(systemName: "location.north.fill")
                .font(.system(size: indicatorSize * 0.58, weight: .semibold))
                .foregroundStyle(.tint)
                .opacity(headingDegrees == nil ? 0.45 : 1)
                .rotationEffect(.degrees(currentRotationDegrees))
        }
        .frame(width: indicatorSize, height: indicatorSize)
        .accessibilityHidden(true)
        .onAppear {
            displayedRotationDegrees = targetRotationDegrees
        }
        .onChange(of: targetRotationDegrees) { _, newValue in
            updateDisplayedRotation(to: newValue)
        }
        .onChange(of: reduceMotion) { _, _ in
            displayedRotationDegrees = targetRotationDegrees
        }
    }

    private func updateDisplayedRotation(to targetDegrees: Double) {
        let currentDegrees = displayedRotationDegrees ?? targetDegrees
        let shortestDelta = (targetDegrees - currentDegrees).shortestSignedDegrees
        let nextDegrees = currentDegrees + shortestDelta

        guard !reduceMotion else {
            displayedRotationDegrees = nextDegrees
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            displayedRotationDegrees = nextDegrees
        }
    }
}

private extension Double {
    var normalizedDegrees: Double {
        let value = truncatingRemainder(dividingBy: 360)
        return value >= 0 ? value : value + 360
    }

    var shortestSignedDegrees: Double {
        let value = (self + 180).truncatingRemainder(dividingBy: 360)
        let normalizedValue = value >= 0 ? value : value + 360
        return normalizedValue - 180
    }
}

#Preview {
    VStack(spacing: 32) {
        DirectionIndicatorView(bearingDegrees: 45, headingDegrees: 0)
        DirectionIndicatorView(bearingDegrees: 45, headingDegrees: nil)
    }
    .padding()
}
