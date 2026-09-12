import SwiftUI

/// The hand-off links a reply offers.
///
/// Nothing above them: whatever explains the hand-off arrives as its own reply
/// bubble, so a heading here would introduce a thing the sentence before it
/// has already introduced.
public struct ActionBubble: View {
    let payload: ActionPayload
    let onAction: (Action) -> Void

    public init(
        payload: ActionPayload,
        onAction: @escaping (Action) -> Void
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
                ActionLink(button: button, onTap: onAction)
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
