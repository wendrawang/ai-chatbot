import Combine
import Foundation
import TanyaAIContracts
import TanyaAIDomain

public final class TanyaAIChatViewModel: ObservableObject {
    @Published public private(set) var messages: [TanyaAIMessageItemViewModel]
    @Published public private(set) var isGenerating = false
    /// The agent or bot is composing between turns, reported by the channel
    /// rather than by a turn the customer started.
    @Published public private(set) var isAgentTyping = false
    /// True until the channel reports what it already held. The conversation
    /// stays empty meanwhile, so a greeting is never shown and then replaced.
    @Published public private(set) var isRestoring = true
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

    /// Whether the host injected an authorization service, and so whether a
    /// confirmation without a hand-off can be completed in the chat.
    let authorizesInFeature: Bool

    public init(
        useCase: TanyaAIChatUseCaseProtocol,
        authorizesInFeature: Bool = true
    ) {
        self.useCase = useCase
        self.authorizesInFeature = authorizesInFeature
        messages = []
        suggestions = TanyaAISuggestion.sandboxDefaults
        // A reply nobody asked for still belongs on screen. Without this the
        // channel delivers it and the graph drops it on the floor.
        useCase.observeUnsolicitedEvents { [weak self] event in
            self?.performOnMain {
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
        isRestoring = false
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
        !isGenerating && !isRestoring && !suggestions.isEmpty
    }

    /// Whether the waiting bubble belongs at the end of the conversation.
    ///
    /// Separate from `isGenerating`, which also drives the send/stop button: an
    /// agent typing between turns should show the dots without turning the
    /// send button into a stop button for a turn nobody started.
    ///
    /// Restoring is not one of these: it has its own loading state, and dots
    /// promising a reply that nobody asked for would be a lie.
    public var showsTypingRow: Bool {
        isGenerating || isAgentTyping
    }

    public func cancelGeneration() {
        activeRequest?.cancel()
        activeRequest = nil
        textDeltaBuffer.flushAll()
        isGenerating = false
    }

    /// Puts a reopened conversation on screen.
    ///
    /// Replaces rather than appends: a returning customer should see where
    /// they left off. An empty batch means there is nothing to come back to,
    /// so this is where the greeting is finally earned.
    private func restore(_ restored: [TanyaAIMessage]) {
        isRestoring = false
        // The customer may have typed before the channel answered. What they
        // sent is newer than what it holds, so replacing here would delete
        // their message, and the reply on its way to it.
        guard messages.isEmpty else {
            return
        }
        guard restored.isEmpty == false else {
            // Nothing to come back to, so this is a first conversation.
            messages = [Self.makeWelcomeMessage()]
            return
        }
        messages = restored.map(TanyaAIMessageItemViewModel.init)
    }

    /// A confirmation arrived that this app cannot complete, because no
    /// authorization service was injected. Says so instead of leaving the
    /// customer with a Confirm button that does nothing.
    func reportUnauthorizableApproval() {
        errorMessage = "This confirmation has to be completed in the app."
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
        case .history(let restored):
            restore(restored)
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

}
