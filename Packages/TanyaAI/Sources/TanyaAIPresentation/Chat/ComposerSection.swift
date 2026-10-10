import DesignKit
import SwiftUI

/// Editing is local: keystrokes do not invalidate the screen or message table.
struct ComposerSection: View {
    @Environment(\.copyCatalog) private var copy
    @State private var text = ""
    let isEnabled: Bool
    let draftRequest: TanyaAIDraftRequest?
    let onSend: (String) -> Bool

    var body: some View {
        MessageComposer(
            text: $text,
            placeholder: copy.chat("chat.placeholder"),
            sendLabel: copy.chat("chat.send"),
            isEnabled: isEnabled,
            onSend: submit
        )
        .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
        .padding(.vertical, FigmaSize.spacing8.sizeInArtwork)
        .onChange(of: draftRequest) { request in
            if let request { text = request.text }
        }
    }

    private func submit() {
        if onSend(text) { text = "" }
    }
}
