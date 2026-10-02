import Foundation
import TanyaAIDomain

public extension TanyaAIChatViewModel {
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
