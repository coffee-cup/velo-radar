import SwiftUI

struct ModePickerView: View {
    let onSelect: (SearchMode) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

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

            Text("Live BIXI availability")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.background)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WhereBixi")
                .font(.largeTitle.bold())

            Text("What do you need?")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ModeChoiceCard: View {
    let mode: SearchMode

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: mode.systemImageName)
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.tint)

            VStack(spacing: 8) {
                Text(mode.title)
                    .font(.title.bold())
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
        .background(.regularMaterial, in: .rect(cornerRadius: 32, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
        .contentShape(.rect(cornerRadius: 32, style: .continuous))
    }
}

#Preview {
    ModePickerView { _ in }
}
