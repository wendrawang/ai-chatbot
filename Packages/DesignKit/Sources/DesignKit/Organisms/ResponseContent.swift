import SwiftUI

/// Optional text, options, media, and caller-supplied actions in reading order.
/// Selection and navigation are reported to the caller; the layout owns no session state.
public struct ResponseContent<ActionContent: View>: View {
    private let text: String?
    private let options: [SelectionOption]
    private let image: ImagePayload?
    private let onSelect: (SelectionOption) -> Void
    private let actionContent: ActionContent
    private let selectedIdentifier: String?
    private let isOptionsEnabled: Bool
    private let onLink: ((URL) -> Void)?

    public init(
        text: String? = nil,
        options: [SelectionOption] = [],
        image: ImagePayload? = nil,
        selectedIdentifier: String? = nil,
        isOptionsEnabled: Bool = true,
        onLink: ((URL) -> Void)? = nil,
        onSelect: @escaping (SelectionOption) -> Void,
        @ViewBuilder actions: () -> ActionContent
    ) {
        self.text = text
        self.options = options
        self.image = image
        self.selectedIdentifier = selectedIdentifier
        self.isOptionsEnabled = isOptionsEnabled
        self.onLink = onLink
        self.onSelect = onSelect
        actionContent = actions()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignKitMetrics.Spacing.roomy.sizeInArtwork) {
            if let text, text.isEmpty == false {
                TextBubble(text: text, isUser: false, onLink: onLink)
            }
            if options.isEmpty == false {
                OptionList(
                    title: nil, options: options, selectedIdentifier: selectedIdentifier,
                    isEnabled: isOptionsEnabled, onSelect: onSelect
                )
            }
            if let image {
                ImageBubble(payload: image)
            }
            actionContent
        }
        .frame(maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth.sizeInArtwork, alignment: .leading)
        .accessibilityElement(children: .contain)
    }
}
