import SwiftUI

/// A static HTML fragment, in a bubble.
///
/// For results that read better as a table than as a card. Charts belong in
/// `ChartBubble`: it follows the theme, scales with Dynamic Type and can be
/// read aloud, none of which survive inside a web view.
public struct HTMLBubble: View {
    let payload: HTMLPayload
    @Environment(\.theme) private var theme
    @State private var height: CGFloat

    public init(payload: HTMLPayload) {
        self.payload = payload
        // Starts at the declared height so the row is the right size before
        // anything renders. A measured correction afterwards moves the
        // conversation under the reader, which is what `declaredHeight` is
        // there to avoid.
        _height = State(initialValue: payload.initialHeight)
    }

    public var body: some View {
        HTMLWebView(
            html: payload.html,
            theme: theme,
            onHeightChange: adopt
        )
        .frame(height: height)
        .padding(DesignKitMetrics.Spacing.regular)
        .background(OutlinedBackground())
        .frame(
            maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth,
            alignment: .leading
        )
        .accessibilityElement(children: .ignore)
        .accessibility(
            label: Text(payload.accessibilityText ?? "Formatted result")
        )
        .accessibilityIdentifier("html.card")
    }

    /// Takes the measured height, but only when it differs enough to matter.
    ///
    /// A web view reports its size more than once while laying out, and
    /// resizing the row on every report makes the conversation twitch.
    private func adopt(_ measured: CGFloat) {
        guard abs(measured - height) > 1 else {
            return
        }
        height = measured
    }
}
