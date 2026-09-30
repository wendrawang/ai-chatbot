import SwiftUI

public struct InformationBubble: View {
    let payload: InformationPayload
    @Environment(\.theme) private var theme

    public init(payload: InformationPayload) {
        self.payload = payload
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignKitMetrics.Spacing.regular) {
            if let title = payload.title {
                Text(title)
                    .font(Font(theme.fonts.headline))
            }

            ForEach(payload.blocks.indices, id: \.self) { index in
                blockView(payload.blocks[index])
            }
        }
        .padding(DesignKitMetrics.Spacing.wide)
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Radius.notice)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityIdentifier("information.card")
    }

    @ViewBuilder
    private func blockView(_ block: InformationBlock) -> some View {
        switch block {
        case .text(let text):
            Text(text).font(Font(theme.fonts.body))
        case .keyValue(let items):
            keyValueList(items)
        case .bulletList(let items):
            bulletList(items)
        case .notice(let text):
            Text(text)
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.secondaryText))
        case .divider:
            Rectangle()
                .fill(Color(theme.colors.divider))
                .frame(height: 0.5)
        }
    }

    private func keyValueList(_ items: [KeyValue]) -> some View {
        VStack(spacing: DesignKitMetrics.Spacing.compact) {
            ForEach(items.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline) {
                    Text(items[index].label)
                        .foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: 16)
                    Text(items[index].value)
                        .fontWeight(.semibold)
                }
                .font(Font(theme.fonts.subheadline))
            }
        }
    }

    private func bulletList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: DesignKitMetrics.Spacing.snug) {
            ForEach(items.indices, id: \.self) { index in
                Text("• \(items[index])")
                    .font(Font(theme.fonts.subheadline))
            }
        }
    }
}
