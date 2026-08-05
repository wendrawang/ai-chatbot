import SwiftUI
import TanyaAIDomain

struct TanyaAIInformationBubble: View {
    let payload: TanyaAIInformationPayload
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = payload.title {
                Text(title)
                    .font(theme.fonts.headline)
            }

            ForEach(payload.blocks.indices, id: \.self) { index in
                blockView(payload.blocks[index])
            }
        }
        .padding(16)
        .background(theme.colors.surface)
        .cornerRadius(16)
        .frame(maxWidth: 340, alignment: .leading)
        .tanyaAIAccessibilityIdentifier("information.card")
    }

    @ViewBuilder
    private func blockView(_ block: TanyaAIInformationBlock) -> some View {
        switch block {
        case .text(let text):
            Text(text).font(theme.fonts.body)
        case .keyValue(let items):
            keyValueList(items)
        case .bulletList(let items):
            bulletList(items)
        case .notice(let text):
            Text(text)
                .font(theme.fonts.footnote)
                .foregroundColor(theme.colors.secondaryText)
        case .divider:
            Rectangle()
                .fill(theme.colors.divider)
                .frame(height: 0.5)
        }
    }

    private func keyValueList(_ items: [TanyaAIKeyValue]) -> some View {
        VStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline) {
                    Text(items[index].label)
                        .foregroundColor(theme.colors.secondaryText)
                    Spacer(minLength: 16)
                    Text(items[index].value)
                        .fontWeight(.semibold)
                }
                .font(theme.fonts.subheadline)
            }
        }
    }

    private func bulletList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items.indices, id: \.self) { index in
                Text("• \(items[index])")
                    .font(theme.fonts.subheadline)
            }
        }
    }
}
