import SwiftUI

/// The hand-off links a reply offers.
///
/// Nothing above them: whatever explains the hand-off arrives as its own reply
/// bubble, so a heading here would introduce a thing the sentence before it
/// has already introduced.
public struct TanyaAIActionBubble: View {
    let payload: TanyaAIActionPayload
    let onAction: (TanyaAIAction) -> Void

    public init(
        payload: TanyaAIActionPayload,
        onAction: @escaping (TanyaAIAction) -> Void
    ) {
        self.payload = payload
        self.onAction = onAction
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: DesignKitMetrics.Spacing.compact
        ) {
            ForEach(payload.buttons) { button in
                TanyaAIActionLink(button: button, onTap: onAction)
            }
        }
        .frame(
            maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth,
            alignment: .leading
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("actions.card")
    }
}
