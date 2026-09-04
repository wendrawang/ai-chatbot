import Combine
import Foundation
import TanyaAIContracts
import TanyaAIDomain

public final class TanyaAIChatViewModel: ObservableObject {
    @Published public private(set) var messages: [TanyaAIMessageItemViewModel]
    @Published public private(set) var isGenerating = false
    /// The agent or bot is composing between turns. Only a session transport
    /// reports this; over SSE it stays false.
    @Published public private(set) var isAgentTyping = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var suggestions: [TanyaAISuggestion]
    @Published public var inputText = ""

    public var onOutput: ((TanyaAIChatOutput) -> Void)?

    private let useCase: TanyaAIChatUseCaseProtocol
    /// Maps a message identifier the backend reuses onto the bubble that
    /// replaced a settled confirmation. See `appendContent`.
    var redirectedIdentifiers: [String: String] = [:]
    private var activeRequest: TanyaAICancellable?
    private var conversationIdentifier: String?
    private lazy var textDeltaBuffer = TanyaAITextDeltaBuffer { [weak self] identifier, text in
        self?.appendTextDeltaNow(
            identifier: identifier,
            text: text
        )
    }

    public init(useCase: TanyaAIChatUseCaseProtocol) {
        self.useCase = useCase
        messages = [Self.makeWelcomeMessage()]
        suggestions = TanyaAISuggestion.sandboxDefaults
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

    /// Whether the waiting bubble belongs at the end of the conversation.
    ///
    /// Separate from `isGenerating`, which also drives the send/stop button: an
    /// agent typing between turns should show the dots without turning the
    /// send button into a stop button for a turn nobody started.
    public var showsTypingRow: Bool {
        isGenerating || isAgentTyping
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
                self?.performOnMain {
                    self?.handle(event)
                }
            },
            completion: { [weak self] result in
                self?.performOnMain {
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

    func appendMessage(_ message: TanyaAIMessageItemViewModel) {
        messages.append(message)
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
        let target = resolvedIdentifier(for: identifier)
        if let existing = message(identifier: target),
           isSettledApproval(existing.content) == false {
            return
        }
        appendContent(identifier: identifier, content: .text(""))
    }

    private func appendTextDeltaNow(identifier: String, text: String) {
        // Text may not overwrite a settled confirmation either: routing
        // through `appendContent` gives the delta a fresh bubble.
        let target = resolvedIdentifier(for: identifier)
        guard let message = message(identifier: target),
              isSettledApproval(message.content) == false else {
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

    func message(identifier: String) -> TanyaAIMessageItemViewModel? {
        messages.first { $0.id == identifier }
    }

    /// The newest bubble carrying this approval identifier.
    ///
    /// A settled confirmation stays on screen, so a repeated approval creates
    /// a second bubble; state updates belong to the newest one.
    func approvalMessage(
        identifier: String
    ) -> TanyaAIMessageItemViewModel? {
        messages.last { message in
            guard case .approval(let payload) = message.content else {
                return false
            }
            return payload.approvalIdentifier == identifier
        }
    }
    private func performOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }

    private static func makeWelcomeMessage() -> TanyaAIMessageItemViewModel {
        let message = TanyaAIMessage(
            identifier: "sandbox-welcome",
            role: .assistant,
            content: .text(
                "[bold]Welcome to the sanitized Tanya AI "
                    + "sandbox.[/bold] "
                    + "Ask for a sample portfolio to start the demo."
            )
        )
        return TanyaAIMessageItemViewModel(message: message)
    }
}
