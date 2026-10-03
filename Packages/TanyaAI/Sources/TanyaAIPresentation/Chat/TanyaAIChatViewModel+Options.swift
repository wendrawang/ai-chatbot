import Foundation
import TanyaAIDomain

public extension TanyaAIChatViewModel {
    /// A confirmation reference is handed to the host's existing PIN flow.
    func confirm(_ payload: ConfirmationPayload) {
        guard isConfirmationEnabled else { reportUnauthorizableApproval(); return }
        guard !isConfirmationRequested else { return }
        isConfirmationRequested = true
        onOutput?(.requestConfirmation(payload))
    }

    /// Sends one radio option and consumes only that answer's option list.
    func selectAnswerOption(_ messageIdentifier: String, _ optionIdentifier: String) {
        guard !isGenerating, !isRestoring,
              let message = message(identifier: messageIdentifier),
              case .answer(let payload) = message.content,
              !payload.isAnswered,
              let option = payload.options.first(where: { $0.identifier == optionIdentifier }),
              !option.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        message.consumeOptions()
        sendMessage(option.prompt)
    }
}
