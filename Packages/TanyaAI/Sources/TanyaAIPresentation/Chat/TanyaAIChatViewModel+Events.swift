import TanyaAIDomain

extension TanyaAIChatViewModel {
    func handle(_ event: TanyaAIStreamEvent) {
        switch event {
        case .connectionChanged(let state):
            connectionChanged(state)
        case .historyFailed:
            isRestoring = false
            isHistoryUnavailable = true
            errorMessage = copy.chat("chat.historyUnavailable")
        case .sendSucceeded(let identifier, let remoteIdentifier):
            finishSubmission(identifier, remoteIdentifier: remoteIdentifier, isSuccessful: true)
        case .sendFailed(let identifier):
            finishSubmission(identifier, remoteIdentifier: nil, isSuccessful: false)
        default:
            receiveContent(event)
        }
    }

    private func receiveContent(_ event: TanyaAIStreamEvent) {
        switch event {
        case .responseStarted(let identifier):
            appendAssistantPlaceholder(identifier: identifier)
        case .textDelta(let identifier, let text):
            textDeltaBuffer.append(messageIdentifier: identifier, text: text)
        case .content(let identifier, let content):
            appendContent(identifier: identifier, content: content)
        case .suggestions(let title, let payloads):
            suggestionsTitle = title
            suggestions = payloads.map(makeSuggestion)
        case .responseCompleted(let identifier):
            textDeltaBuffer.flush(messageIdentifier: identifier)
        case .hostAction(let action):
            onOutput?(.performAction(action))
        case .typing(let isTyping):
            isAgentTyping = isTyping
        case .history(let restored):
            restore(restored)
        default:
            break
        }
    }

    private func connectionChanged(_ state: TanyaAIConnectionState) {
        connection = state
        isRestoring = state == .connecting
        if state == .ready {
            sendInitialPromptIfReady()
        } else if state == .failed || state == .closed {
            isAgentTyping = false
            textDeltaBuffer.flushAll()
            failPendingSubmissions()
            errorMessage = copy.chat("chat.connectionFailed")
        }
    }
}
