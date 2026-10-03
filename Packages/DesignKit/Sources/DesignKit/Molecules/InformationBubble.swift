import SwiftUI

public struct InformationBubble: View {
    let payload: InformationPayload
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init(payload: InformationPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
            if let title = payload.title {
                Text(title)
                    .designFont(.headline)
            }

            ForEach(payload.blocks.indices, id: \.self) { index in
                blockView(payload.blocks[index])
            }
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(artwork.size(DesignKitMetrics.Spacing.wide))
        .background(Color(theme.colors.surface))
        .cornerRadius(artwork.size(DesignKitMetrics.Radius.notice))
        .frame(maxWidth: artwork.size(DesignKitMetrics.Size.cardMaximumWidth), alignment: .leading)
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
                .frame(height: artwork.stroke(DesignKitMetrics.Stroke.divider))
        }
    }

    private func keyValueList(_ items: [KeyValue]) -> some View {
        VStack(spacing: artwork.size(DesignKitMetrics.Spacing.compact)) {
            ForEach(items.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: artwork.size(DesignKitMetrics.Spacing.compact)) {
                    Text(items[index].label)
                        .foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: artwork.size(DesignKitMetrics.Spacing.wide))
                    Text(items[index].value)
                        .fontWeight(.semibold)
                }
                .designFont(.subheadline)
            }
        }
    }

    private func bulletList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: artwork.size(DesignKitMetrics.Spacing.snug)) {
            ForEach(items.indices, id: \.self) { index in
                Text("• \(items[index])")
                    .designFont(.subheadline)
            }
        }
    }
}
