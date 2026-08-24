import Foundation
import TanyaAIDomain

extension TanyaAIStreamEventDecoder {
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

    func makeAction(_ dto: TanyaAIActionDTO) -> TanyaAIAction {
        TanyaAIAction(
            identifier: dto.identifier,
            route: dto.route,
            parameters: dto.parameters ?? [:]
        )
    }

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
