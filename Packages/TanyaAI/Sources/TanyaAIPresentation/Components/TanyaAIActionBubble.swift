import SwiftUI
import TanyaAIDomain

struct TanyaAIActionBubble: View {
    let payload: TanyaAIActionPayload
    let onAction: (TanyaAIAction) -> Void
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            buttons
        }
        .padding(16)
        .background(theme.colors.surface)
        .cornerRadius(18)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityElement(children: .contain)
        .tanyaAIAccessibilityIdentifier("actions.card")
    }

    @ViewBuilder
    private var header: some View {
        if payload.title != nil || payload.detail != nil {
            VStack(alignment: .leading, spacing: 4) {
                if let title = payload.title {
                    Text(title)
                        .font(theme.fonts.headline)
                        .foregroundColor(theme.colors.primaryText)
                }
                if let detail = payload.detail {
                    Text(detail)
                        .font(theme.fonts.subheadline)
                        .foregroundColor(theme.colors.secondaryText)
                }
            }
        }
    }

    private var buttons: some View {
        VStack(spacing: 8) {
            ForEach(payload.buttons) { button in
                Button {
                    onAction(button.action)
                } label: {
                    Text(button.title)
                        .font(theme.fonts.button)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundColor(foregroundColor(for: button.style))
                .background(backgroundColor(for: button.style))
                .cornerRadius(12)
                .tanyaAIAccessibilityIdentifier(
                    "action.\(button.action.identifier)"
                )
            }
        }
    }

    private func foregroundColor(
        for style: TanyaAIActionButton.Style
    ) -> Color {
        switch style {
        case .primary: return theme.colors.userBubbleText
        case .secondary: return theme.colors.primaryText
        }
    }

    private func backgroundColor(
        for style: TanyaAIActionButton.Style
    ) -> Color {
        switch style {
        case .primary: return theme.colors.accent
        case .secondary: return theme.colors.background
        }
    }
}
