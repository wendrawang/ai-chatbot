import DesignKit
import SwiftUI

/// Stage one: a blank conversation area and a locally owned composer draft.
@MainActor
public struct ChatScreen: View {
    @Environment(\.locale)
    private var locale
    @State
    private var text = InitialValues.emptyString
    private let isEnabled: Bool
    private let onSend: (String) -> Bool

    /// Return true when the host accepts the submission; false preserves the draft.
    public init(isEnabled: Bool = InitialValues.isEnabled, onSend: @escaping (String) -> Bool) {
        self.isEnabled = isEnabled
        self.onSend = onSend
    }

    public var body: some View {
        VStack(spacing: InitialValues.zeroCGFloat) {
            Spacer(minLength: InitialValues.zeroCGFloat)
            MessageComposer(
                text: $text, placeholder: ChatCopy.placeholder.text(locale: locale),
                sendLabel: ChatCopy.send.text(locale: locale), isEnabled: isEnabled,
                onSend: submit
            )
            .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
            .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
        }
        .background(DefaultColorConstants().colorsSurfacePrimary.ignoresSafeArea())
    }

    private func submit() {
        guard onSend(text) else { return }
        text = InitialValues.emptyString
    }
}
