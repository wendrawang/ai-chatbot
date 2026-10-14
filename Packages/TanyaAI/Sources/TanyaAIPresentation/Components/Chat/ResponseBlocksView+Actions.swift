import DesignKit
import SwiftUI
import TanyaAIDomain

extension ResponseBlocksView {
    func isVisible(_ action: ResponseAction) -> Bool {
        action.intent == .destination || !payload.isReadOnly
    }

    func responseAction(_ action: ResponseAction) -> some View {
        actionControl(action)
            .accessibilityIdentifier("response.action.\(action.identifier)")
    }

    @ViewBuilder
    private func actionControl(_ action: ResponseAction) -> some View {
        let isEnabled = action.intent != .prompt || handlers.isSendEnabled
        switch action.presentation ?? .outlined {
        case .outlined:
            ActionPill(title: action.title, symbolName: action.symbolName, isEnabled: isEnabled) {
                handlers.onResponseAction(messageIdentifier, action)
            }
        case .link:
            LinkAction(title: action.title, isEnabled: isEnabled) {
                handlers.onResponseAction(messageIdentifier, action)
            }
        case .filled:
            FilledAction(
                title: action.title, isEnabled: isEnabled,
                onTap: {
                    handlers.onResponseAction(messageIdentifier, action)
                },
                icon: {
                    // TODO: Replace the symbol with the approved CTA emblem from Figma.
                    Image(systemName: action.symbolName ?? "sparkles").resizable().scaledToFit()
                }
            )
        }
    }
}
