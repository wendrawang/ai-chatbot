import Foundation
import TanyaAIDomain

extension TanyaAIStreamEventDecoder {
    /// Decodes a `content.actions` event into an action card.
    ///
    /// An empty button list is not an empty card: it degrades to the same
    /// unsupported fallback as an unknown content type, so a malformed
    /// response cannot render a card nobody can act on.
    func decodeActions(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIActionsDTO.self, from: data)
        let buttons = payload.actions.map(makeActionButton)

        guard !buttons.isEmpty else {
            return .content(
                messageIdentifier: payload.messageIdentifier,
                content: .unsupported(
                    "This action requires a newer app version."
                )
            )
        }

        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: .actions(
                TanyaAIActionPayload(
                    title: payload.title,
                    detail: payload.detail,
                    buttons: buttons
                )
            )
        )
    }

    /// Maps a transport action into the domain model.
    ///
    /// The deeplink is carried through untouched. Validation belongs to the
    /// host, which is the only layer that knows what the app can open.
    func makeAction(_ dto: TanyaAIActionDTO) -> TanyaAIAction {
        TanyaAIAction(
            identifier: dto.identifier,
            deeplink: dto.deeplink
        )
    }

    /// An unknown style falls back to `primary` instead of failing the stream.
    private func makeActionButton(
        _ dto: TanyaAIActionButtonDTO
    ) -> TanyaAIActionButton {
        TanyaAIActionButton(
            title: dto.title,
            style: TanyaAIActionButton.Style(
                rawValue: dto.style ?? "primary"
            ) ?? .primary,
            action: makeAction(dto.action)
        )
    }
}
