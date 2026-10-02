import DesignKit
import TanyaAIDomain
import SwiftUI

/// The hand-off links a reply offers.
///
/// Nothing above them: whatever explains the hand-off arrives as its own reply
/// bubble, so a heading here would introduce a thing the sentence before it
/// has already introduced.
public struct ActionBubble: View {
    @Environment(\.artwork) private var artwork
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
            spacing: artwork.size(DesignKitMetrics.Spacing.compact)
        ) {
            ForEach(payload.buttons, id: \.identifier) { button in
                ActionLink(title: button.title, isUnderlined: button.style == .primary) {
                    onAction(button.action)
                }
                .accessibilityIdentifier("action.\(button.action.identifier)")
            }
        }
        .frame(
            maxWidth: artwork.size(DesignKitMetrics.Size.bubbleMaximumWidth),
            alignment: .leading
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("actions.card")
    }
}
