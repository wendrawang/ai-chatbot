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
        .background(Color(theme.colors.surface))
        .cornerRadius(18)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("actions.card")
    }

    @ViewBuilder
    private var header: some View {
        if payload.title != nil || payload.detail != nil {
            VStack(alignment: .leading, spacing: 4) {
                if let title = payload.title {
                    Text(title)
                        .font(Font(theme.fonts.headline))
                        .foregroundColor(Color(theme.colors.primaryText))
                }
                if let detail = payload.detail {
                    Text(detail)
                        .font(Font(theme.fonts.subheadline))
                        .foregroundColor(Color(theme.colors.secondaryText))
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
                        .font(Font(theme.fonts.button))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundColor(foregroundColor(for: button.style))
                .background(backgroundColor(for: button.style))
                .cornerRadius(12)
                .accessibilityIdentifier(
                    "action.\(button.action.identifier)"
                )
            }
        }
    }

    private func foregroundColor(
        for style: TanyaAIActionButton.Style
    ) -> Color {
        switch style {
        case .primary: return Color(theme.colors.userBubbleText)
        case .secondary: return Color(theme.colors.primaryText)
        }
    }

    private func backgroundColor(
        for style: TanyaAIActionButton.Style
    ) -> Color {
        switch style {
        case .primary: return Color(theme.colors.accent)
        case .secondary: return Color(theme.colors.background)
        }
    }
}
