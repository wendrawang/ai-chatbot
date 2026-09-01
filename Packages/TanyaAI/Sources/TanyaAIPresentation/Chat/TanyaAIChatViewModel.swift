import Combine
import Foundation
import TanyaAIContracts
import TanyaAIDomain

public final class TanyaAIChatViewModel: ObservableObject {
    @Published public private(set) var messages: [TanyaAIMessageItemViewModel]
    @Published public private(set) var isGenerating = false
    /// True while the agent or bot is composing on a session transport.
    @Published public private(set) var isAgentTyping = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var suggestions: [TanyaAISuggestion]
    @Published public var inputText = ""

    public var onOutput: ((TanyaAIChatOutput) -> Void)?

    private let useCase: TanyaAIChatUseCaseProtocol
    private var activeRequest: TanyaAICancellable?
    private var conversationIdentifier: String?
    private var messageStore: TanyaAIMessageStore
    private lazy var textDeltaBuffer = TanyaAITextDeltaBuffer {
        [weak self] messageIdentifier, text in

        self?.appendTextDeltaNow(
            identifier: messageIdentifier,
            text: text
        )
    }

    public init(useCase: TanyaAIChatUseCaseProtocol) {
        self.useCase = useCase
        let welcomeMessage = TanyaAIWelcomeMessageFactory.makeMessage()
        messages = [welcomeMessage]
        messageStore = TanyaAIMessageStore(welcomeMessage: welcomeMessage)
        suggestions = TanyaAISuggestion.sandboxDefaults
        observeUnsolicitedEvents()
    }

    /// A session transport delivers messages nobody asked for - an agent
    /// replying on their own, or a hand-off pushed by the channel. Over SSE
    /// this observer is never called.
    private func observeUnsolicitedEvents() {
        useCase.observeUnsolicitedEvents { [weak self] event in
            TanyaAIMainQueue.perform {
                self?.handle(event)
            }
        }
    }

    public func sendCurrentMessage() {
        let message = inputText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !message.isEmpty, !isGenerating else {
            return
        }

        inputText = ""
        errorMessage = nil
        suggestions = []
        isGenerating = true
        appendUserMessage(message)
        startRequest(message)
    }

    public func sendSuggestion(_ suggestion: TanyaAISuggestion) {
        suggestions = []
        sendMessage(suggestion.prompt)
    }

    public func sendMessage(_ text: String) {
        inputText = text
        sendCurrentMessage()
    }

    public var showsSuggestions: Bool {
        !isGenerating && !suggestions.isEmpty
    }

    public func cancelGeneration() {
        activeRequest?.cancel()
        activeRequest = nil
        textDeltaBuffer.flushAll()
        isGenerating = false
    }

    public func close() {
        onOutput?(.close)
    }

    public func openHistory() {
        onOutput?(.openHistory)
    }

    deinit {
        activeRequest?.cancel()
        textDeltaBuffer.cancel()
    }

    private func startRequest(_ text: String) {
        activeRequest = useCase.sendMessage(
            conversationIdentifier: conversationIdentifier,
            text: text,
            onEvent: { [weak self] event in
                TanyaAIMainQueue.perform {
                    [weak self] in
                    self?.handle(event)
                }
            },
            completion: { [weak self] result in
                TanyaAIMainQueue.perform {
                    [weak self] in
                    self?.handleCompletion(result)
                }
            }
        )
    }

    private func handle(_ event: TanyaAIStreamEvent) {
        switch event {
        case .responseStarted(let messageIdentifier):
            appendAssistantPlaceholder(identifier: messageIdentifier)
        case .textDelta(let messageIdentifier, let text):
            textDeltaBuffer.append(
                messageIdentifier: messageIdentifier,
                text: text
            )
        case .content(let messageIdentifier, let content):
            appendContent(identifier: messageIdentifier, content: content)
        case .suggestions(let payloads):
            suggestions = payloads.map(makeSuggestion)
        case .responseCompleted:
            textDeltaBuffer.flushAll()
            isGenerating = false
            isAgentTyping = false
            activeRequest = nil
        case .hostAction(let action):
            onOutput?(.performAction(action))
        case .typing(let isTyping):
            isAgentTyping = isTyping
        case .heartbeat:
            break
        }
    }

    private func handleCompletion(_ result: Result<Void, Error>) {
        activeRequest = nil
        textDeltaBuffer.flushAll()
        isGenerating = false
        if case .failure = result {
            errorMessage = "The response was interrupted. Please try again."
        }
    }

    private func appendUserMessage(_ text: String) {
        let message = TanyaAIMessage(
            identifier: UUID().uuidString,
            role: .user,
            content: .text(text)
        )
        appendMessage(TanyaAIMessageItemViewModel(message: message))
    }

    private func makeSuggestion(
        _ payload: TanyaAISuggestionPayload
    ) -> TanyaAISuggestion {
        TanyaAISuggestion(
            identifier: payload.identifier,
            title: payload.title,
            prompt: payload.prompt
        )
    }

    private func appendAssistantPlaceholder(identifier: String) {
        guard message(identifier: identifier) == nil else {
            return
        }
        appendContent(identifier: identifier, content: .text(""))
    }

    private func appendTextDeltaNow(identifier: String, text: String) {
        guard let message = message(identifier: identifier) else {
            appendContent(identifier: identifier, content: .text(text))
            return
        }
        let existingText: String
        if case .text(let value) = message.content {
            existingText = value
        } else {
            existingText = ""
        }
        message.update(content: .text(existingText + text))
    }

    private func appendContent(
        identifier: String,
        content: TanyaAIMessageContent
    ) {
        if let existingMessage = message(identifier: identifier) {
            existingMessage.update(content: content)
            indexApproval(content, message: existingMessage)
            return
        }
        let message = TanyaAIMessage(
            identifier: identifier,
            role: .assistant,
            content: content
        )
        let itemViewModel = TanyaAIMessageItemViewModel(message: message)
        appendMessage(itemViewModel)
        indexApproval(content, message: itemViewModel)
    }

    private func message(identifier: String) -> TanyaAIMessageItemViewModel? {
        messageStore.message(identifier: identifier)
    }

    func approvalMessage(
        identifier: String
    ) -> TanyaAIMessageItemViewModel? {
        messageStore.approval(identifier: identifier)
    }

    private func appendMessage(_ message: TanyaAIMessageItemViewModel) {
        messageStore.append(message)
        messages.append(message)
    }

    private func indexApproval(
        _ content: TanyaAIMessageContent,
        message: TanyaAIMessageItemViewModel
    ) {
        messageStore.indexApproval(content, message: message)
    }

}
