import TanyaAIDomain

extension TanyaAIChatViewModel {
    /// Places streamed content in the conversation.
    ///
    /// Content usually updates the message it names, which is how a text reply
    /// grows and how an approval moves between states. One case must not
    /// update: a settled approval. A cancelled or completed confirmation is a
    /// record of what the customer did, so a later message about the same
    /// transaction opens a new bubble instead of reopening the old one.
    ///
    /// The replacement is remembered, so every further chunk of that turn -
    /// text deltas included - reaches the new bubble instead of opening one
    /// bubble per chunk.
    func appendContent(
        identifier: String,
        content: TanyaAIMessageContent
    ) {
        let target = resolvedIdentifier(for: identifier)
        guard let existingMessage = message(identifier: target) else {
            appendMessage(identifier: target, content: content)
            return
        }

        guard isSettledApproval(existingMessage.content) == false else {
            let replacement = unusedIdentifier(basedOn: identifier)
            redirectedIdentifiers[identifier] = replacement
            appendMessage(identifier: replacement, content: content)
            return
        }

        existingMessage.update(content: content)
    }

    /// The bubble a message identifier currently belongs to.
    func resolvedIdentifier(for identifier: String) -> String {
        redirectedIdentifiers[identifier] ?? identifier
    }

    func isSettledApproval(_ content: TanyaAIMessageContent) -> Bool {
        guard case .approval(let payload) = content else {
            return false
        }
        return payload.state.isSettled
    }

    private func appendMessage(
        identifier: String,
        content: TanyaAIMessageContent
    ) {
        let message = TanyaAIMessage(
            identifier: identifier,
            role: .assistant,
            content: content
        )
        appendMessage(TanyaAIMessageItemViewModel(message: message))
    }

    /// Derives an identifier the conversation is not already using, so a
    /// backend that reuses one cannot overwrite a settled bubble.
    private func unusedIdentifier(basedOn identifier: String) -> String {
        var attempt = 2
        var candidate = "\(identifier)#\(attempt)"
        while message(identifier: candidate) != nil {
            attempt += 1
            candidate = "\(identifier)#\(attempt)"
        }
        return candidate
    }
}
