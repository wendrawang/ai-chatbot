import SwiftUI

public struct InformationBubble: View {
    let payload: InformationPayload
    @Environment(\.theme) private var theme

    public init(payload: InformationPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
            if let title = payload.title {
                Text(title)
                    .designFont(.headline)
            }

            ForEach(payload.blocks.indices, id: \.self) { index in
                blockView(payload.blocks[index])
            }
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(DesignKitMetrics.Spacing.wide.sizeInArtwork)
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Radius.notice.sizeInArtwork)
        .frame(maxWidth: DesignKitMetrics.Size.cardMaximumWidth.sizeInArtwork, alignment: .leading)
        .accessibilityIdentifier("information.card")
    }

    @ViewBuilder
    private func blockView(_ block: InformationBlock) -> some View {
        switch block {
        case .text(let text):
            Text(text).designFont(.body)
        case .keyValue(let items):
            keyValueList(items)
        case .bulletList(let items):
            bulletList(items)
        case .notice(let text):
            Text(text)
                .designFont(.footnote)
                .foregroundColor(Color(theme.colors.secondaryText))
        case .divider:
            Rectangle()
                .fill(Color(theme.colors.divider))
                .frame(height: DesignKitMetrics.Stroke.divider.strokeInArtwork)
        }
    }

    private func keyValueList(_ items: [KeyValue]) -> some View {
        VStack(spacing: DesignKitMetrics.Spacing.compact.sizeInArtwork) {
            ForEach(items.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: DesignKitMetrics.Spacing.compact.sizeInArtwork) {
                    Text(items[index].label)
                        .foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: DesignKitMetrics.Spacing.wide.sizeInArtwork)
                    Text(items[index].value)
                        .fontWeight(.semibold)
                }
                .designFont(.subheadline)
            }
        }
    }

    private func bulletList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: DesignKitMetrics.Spacing.snug.sizeInArtwork) {
            ForEach(items.indices, id: \.self) { index in
                Text("• \(items[index])")
                    .designFont(.subheadline)
            }
        }
    }
}
