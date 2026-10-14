import TanyaAIDomain

extension TanyaAIChatViewModel {
    func appendContent(identifier: String, content: TanyaAIMessageContent) {
        if let existing = message(identifier: identifier) {
            if messages.last !== existing { existing.consumeOptions() }
            existing.update(content: content)
        } else {
            appendMessage(
                TanyaAIMessageItemViewModel(
                    message: TanyaAIMessage(
                        identifier: identifier, role: .assistant, content: content
                    )))
        }
    }
}
