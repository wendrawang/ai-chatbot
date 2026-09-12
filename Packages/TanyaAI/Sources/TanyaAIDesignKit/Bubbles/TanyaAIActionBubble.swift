import SwiftUI
import TanyaAIDomain

/// The hand-off links a reply offers - "Lihat Produk Sekarang", "Connect
/// dengan Agent".
///
/// Links rather than filled buttons, and nothing above them. Whatever explains
/// the hand-off arrives as its own reply bubble, so a heading here would
/// introduce a thing the sentence before it has already introduced.
public struct TanyaAIActionBubble: View {
    let payload: TanyaAIActionPayload
    let onAction: (TanyaAIAction) -> Void
    @Environment(\.tanyaAITheme) private var theme

    public init(
        payload: TanyaAIActionPayload,
        onAction: @escaping (TanyaAIAction) -> Void
    ) {
        self.payload = payload
        self.onAction = onAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(payload.buttons) { button in
                Button {
                    onAction(button.action)
                } label: {
                    label(for: button)
                }
                // Both weights stay in the accent colour. Greying the
                // secondary one made an available hand-off read as disabled,
                // which is a worse lie than the two looking similar.
                .foregroundColor(Color(theme.colors.accent))
                .background(TanyaAIOutlinedBackground())
                .accessibilityIdentifier(
                    "action.\(button.action.identifier)"
                )
            }
        }
        .frame(maxWidth: 310, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("actions.card")
    }

    private func label(for button: TanyaAIActionButton) -> some View {
        text(for: button)
            .font(Font(theme.fonts.button))
            .padding(.horizontal, 16)
            .frame(minHeight: 44)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Underlined only for the primary weight. `Style` carries no behaviour,
    /// so this is the whole of the difference between the two.
    private func text(for button: TanyaAIActionButton) -> Text {
        let base = Text(button.title)
        switch button.style {
        case .primary: return base.underline()
        case .secondary: return base
        }
    }
}
