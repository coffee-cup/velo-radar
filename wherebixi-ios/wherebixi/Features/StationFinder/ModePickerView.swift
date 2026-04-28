import SwiftUI

struct ModePickerView: View {
    let onSelect: (SearchMode) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 34) {
            VStack(alignment: .center, spacing: 10) {
                Text("Velo Radar")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("Find nearby BIXI bikes and open docks")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)

            VStack(spacing: 16) {
                ForEach(SearchMode.allCases) { mode in
                    Button {
                        onSelect(mode)
                    } label: {
                        ModeChoiceCard(mode: mode)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel(mode.title)
                    .accessibilityHint(mode.subtitle)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background { AppBackground() }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct ModeChoiceCard: View {
    let mode: SearchMode

    private var accentColor: Color {
        AppTheme.Colors.modePickerAccent(for: mode)
    }

    private var cardTint: Color? {
        mode == .bikes ? nil : accentColor.opacity(0.18)
    }

    var body: some View {
        VStack(spacing: 18) {
            icon

            VStack(spacing: 8) {
                Text(mode.title)
                    .font(AppTheme.Typography.modeTitle)
                    .foregroundStyle(.primary)

                Text(mode.subtitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(
            AppTheme.glass(tint: cardTint, interactive: true),
            in: .rect(cornerRadius: AppTheme.CornerRadius.card, style: .continuous)
        )
        .overlay { cardBorder }
        .contentShape(.rect(cornerRadius: AppTheme.CornerRadius.card, style: .continuous))
    }

    @ViewBuilder
    private var icon: some View {
        if mode == .bikes {
            ZStack(alignment: .topTrailing) {
                Image(systemName: mode.systemImageName)
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(accentColor)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(AppTheme.Colors.electricBike, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.85), lineWidth: 1)
                    }
                    .offset(x: 12, y: -8)
            }
            .frame(width: 82, height: 64)
        } else {
            Image(systemName: mode.systemImageName)
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(accentColor)
                .frame(width: 82, height: 64)
        }
    }

    @ViewBuilder
    private var cardBorder: some View {
        let shape = RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card, style: .continuous)

        if mode == .bikes {
            shape.stroke(AppTheme.Colors.glassStroke, lineWidth: 1)
        } else {
            shape.stroke(accentColor.opacity(0.18), lineWidth: 1)
        }
    }
}

#Preview {
    ModePickerView { _ in }
}
