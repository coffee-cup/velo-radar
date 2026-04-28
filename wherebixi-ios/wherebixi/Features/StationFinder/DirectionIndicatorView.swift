import CoreLocation
import SwiftUI

struct DirectionIndicatorView: View {
    let bearingDegrees: CLLocationDirection
    let headingDegrees: CLLocationDirection?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var indicatorSize: CGFloat = 220

    private var rotationDegrees: Double {
        guard let headingDegrees else { return 0 }
        return (bearingDegrees - headingDegrees).normalizedDegrees
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
                .rotationEffect(.degrees(rotationDegrees))
                .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: rotationDegrees)
        }
        .frame(width: indicatorSize, height: indicatorSize)
        .accessibilityHidden(true)
    }
}

private extension Double {
    var normalizedDegrees: Double {
        let value = truncatingRemainder(dividingBy: 360)
        return value >= 0 ? value : value + 360
    }
}

#Preview {
    VStack(spacing: 32) {
        DirectionIndicatorView(bearingDegrees: 45, headingDegrees: 0)
        DirectionIndicatorView(bearingDegrees: 45, headingDegrees: nil)
    }
    .padding()
}
