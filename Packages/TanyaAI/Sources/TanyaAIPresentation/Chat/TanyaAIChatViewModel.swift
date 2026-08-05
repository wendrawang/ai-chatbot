import Combine
import Foundation
import TanyaAIContracts
import TanyaAIDomain

public final class TanyaAIChatViewModel: ObservableObject {
    @Published public private(set) var messages: [TanyaAIMessageItemViewModel]
    @Published public private(set) var isGenerating = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var suggestions: [TanyaAISuggestion]
    @Published public var inputText = ""

    public var onOutput: ((TanyaAIChatOutput) -> Void)?

    private let useCase: TanyaAIChatUseCaseProtocol
    private var activeRequest: TanyaAICancellable?
    private var conversationIdentifier: String?
    private lazy var textDeltaBuffer = TanyaAITextDeltaBuffer {
        [weak self] messageIdentifier, text in

        self?.appendTextDeltaNow(
            identifier: messageIdentifier,
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

    public func approve(_ payload: TanyaAIApprovalPayload) {
        guard payload.state == .awaitingApproval else {
            return
        }
        onOutput?(.requestApproval(payload))
    }

    public func editApproval(_ payload: TanyaAIApprovalPayload) {
        inputText = "Change \(payload.title.lowercased()): "
    }

    public func cancelApproval(_ payload: TanyaAIApprovalPayload) {
        updateApproval(
            identifier: payload.approvalIdentifier,
            state: .cancelled
        )
    }

    public func updateApproval(
        identifier: String,
        state: TanyaAIApprovalPayload.State
    ) {
        guard let message = approvalMessage(identifier: identifier),
              case .approval(var payload) = message.content else {
            return
        }
        payload.state = state
        message.update(content: .approval(payload))
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
            activeRequest = nil
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
        messages.append(TanyaAIMessageItemViewModel(message: message))
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
            return
        }
        let message = TanyaAIMessage(
            identifier: identifier,
            role: .assistant,
            content: content
        )
        messages.append(TanyaAIMessageItemViewModel(message: message))
    }

    private func message(identifier: String) -> TanyaAIMessageItemViewModel? {
        messages.first { $0.id == identifier }
    }

    private func approvalMessage(
        identifier: String
    ) -> TanyaAIMessageItemViewModel? {
        messages.first { message in
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
                "Welcome to the sanitized Tanya AI sandbox. "
                    + "Ask for a sample portfolio to start the demo."
            )
        )
        return TanyaAIMessageItemViewModel(message: message)
    }
}
