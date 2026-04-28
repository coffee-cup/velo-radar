import SwiftUI

struct ModePickerView: View {
    let onSelect: (SearchMode) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
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
        .navigationTitle("WhereBixi")
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct ModeChoiceCard: View {
    let mode: SearchMode

    private var accentColor: Color {
        AppTheme.Colors.modePickerAccent(for: mode)
    }

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: mode.systemImageName)
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(accentColor)

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
            AppTheme.glass(tint: accentColor.opacity(0.22), interactive: true),
            in: .rect(cornerRadius: AppTheme.CornerRadius.card, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card, style: .continuous)
                .stroke(accentColor.opacity(0.22), lineWidth: 1)
        }
        .contentShape(.rect(cornerRadius: AppTheme.CornerRadius.card, style: .continuous))
    }
}

#Preview {
    ModePickerView { _ in }
}
