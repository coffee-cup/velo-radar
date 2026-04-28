import SwiftUI
import UIKit

enum AppTheme {
    enum Colors {
        static let regularBike = Color(uiColor: .systemRed)
        static let electricBike = Color(uiColor: .systemBlue)
        static let dock = Color(uiColor: .systemGray)
        static let glassStroke = Color.primary.opacity(0.10)

        static func accent(for mode: SearchMode, bikePreference: BikePreference = .any) -> Color {
            switch mode {
            case .bikes:
                bikePreference == .electricRequired ? electricBike : regularBike
            case .docks:
                dock
            }
        }

        static func modePickerAccent(for mode: SearchMode) -> Color {
            switch mode {
            case .bikes:
                regularBike
            case .docks:
                dock
            }
        }
    }

    enum CornerRadius {
        static let card: CGFloat = 32
        static let panel: CGFloat = 24
    }

    enum Typography {
        static let heroDistance = Font.system(.largeTitle, design: .rounded, weight: .bold)
        static let modeTitle = Font.system(.title, design: .rounded, weight: .bold)
        static let sectionTitle = Font.system(.title3, design: .rounded, weight: .semibold)
    }

    static func glass(tint color: Color? = nil, interactive: Bool = false) -> Glass {
        Glass.regular.tint(color).interactive(interactive)
    }
}

struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)

            LinearGradient(
                colors: [
                    AppTheme.Colors.electricBike.opacity(colorScheme == .dark ? 0.16 : 0.08),
                    Color.clear,
                    AppTheme.Colors.regularBike.opacity(colorScheme == .dark ? 0.12 : 0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}
