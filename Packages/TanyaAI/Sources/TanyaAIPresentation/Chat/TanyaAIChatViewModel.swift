import Combine
import DesignKit
import Foundation
import TanyaAIDomain

/// Screen workflow and channel state. The editor owns its draft locally.
@MainActor
public final class TanyaAIChatViewModel: ObservableObject {
    @Published
    public internal(set) var messages: [TanyaAIMessageItemViewModel] = []
    @Published
    public internal(set) var connection = TanyaAIConnectionState.connecting
    @Published
    public internal(set) var isRestoring = true
    @Published
    public internal(set) var isAgentTyping = false
    @Published
    public internal(set) var isHistoryUnavailable = false
    @Published
    public internal(set) var errorMessage: String?
    @Published
    public internal(set) var suggestions: [Suggestion] = []
    @Published
    public internal(set) var suggestionsTitle: String?
    @Published
    public internal(set) var draftRequest: TanyaAIDraftRequest?
    @Published
    public private(set) var latestPromptIdentifier: String?

    public let shortcuts: [Suggestion]
    public let welcome: WelcomeConfiguration?
    public let sessionIdentifier = UUID()
    public let sessionStartedAt = Date()
    public private(set) lazy var sessionTimestamp = ChatDateFormat.string(
        from: sessionStartedAt, locale: Locale(identifier: copy.localeIdentifier)
    )
    public let isNewSessionEnabled: Bool
    public let isHostFlowEnabled: Bool
    public var onOutput: ((TanyaAIChatOutput) -> Void)?
    let repository: TanyaAIRepository
    let copy: CopyCatalog
    let isConfirmationEnabled: Bool
    let isAuthorizationEnabled: Bool
    var isConfirmationRequested = false
    var redirectedIdentifiers: [String: String] = [:]
    var pendingSubmissions: [String: String] = [:]
    var pendingHostFlow: PendingHostFlow?
    private var queuedInitialPrompt: String?
    private var isInitialPromptSent = false
    private var isInitialPromptSubmitting = false
    lazy var textDeltaBuffer = TanyaAITextDeltaBuffer { [weak self] identifier, text in
        self?.appendTextDeltaNow(identifier: identifier, text: text)
    }

    public init(
        repository: TanyaAIRepository,
        isAuthorizationEnabled: Bool = true,
        isConfirmationEnabled: Bool = false,
        isHostFlowEnabled: Bool = false,
        isNewSessionEnabled: Bool = false,
        shortcuts: [Suggestion] = [],
        copy: CopyCatalog = CopyCatalog(),
        welcome: WelcomeConfiguration? = nil
    ) {
        self.repository = repository
        self.isAuthorizationEnabled = isAuthorizationEnabled
        self.isConfirmationEnabled = isConfirmationEnabled
        self.shortcuts = shortcuts
        self.copy = copy
        self.welcome = welcome
        self.isHostFlowEnabled = isHostFlowEnabled
        self.isNewSessionEnabled = isNewSessionEnabled
        repository.onEvent = { [weak self] event in self?.handle(event) }
        repository.connect()
    }

    public var isSendEnabled: Bool { connection == .ready && !isRestoring }
    public var isTypingRowVisible: Bool { isAgentTyping }
    public var isShortcutRowVisible: Bool { isSendEnabled && !shortcuts.isEmpty }
    public var isSuggestionRowVisible: Bool { isSendEnabled && !suggestions.isEmpty }
    public var isSessionRetryAvailable: Bool {
        connection == .failed || connection == .closed || isHistoryUnavailable
    }

    /// Returns false without changing the draft or options if the channel is not ready.
    @discardableResult
    public func sendMessage(_ text: String) -> Bool {
        let prompt = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isSendEnabled, !prompt.isEmpty else { return false }
        errorMessage = nil
        suggestions = []
        suggestionsTitle = nil
        let message = appendUserMessage(prompt)
        if !isInitialPromptSubmitting { latestPromptIdentifier = message.identifier }
        submit(message)
        return true
    }

    public func retryMessage(_ identifier: String) {
        guard isSendEnabled, let message = message(identifier: identifier),
            message.delivery == .failed
        else { return }
        messages.last?.consumeOptions()
        errorMessage = nil
        submit(message)
    }

    public func retrySession() {
        guard isSessionRetryAvailable, connection != .connecting else { return }
        isRestoring = true
        isHistoryUnavailable = false
        errorMessage = nil
        repository.disconnect()
        repository.connect()
    }

    public func startInitialPrompt(_ text: String) {
        guard !isInitialPromptSent, queuedInitialPrompt == nil else { return }
        queuedInitialPrompt = text
        sendInitialPromptIfReady()
    }

    func sendInitialPromptIfReady() {
        guard let text = queuedInitialPrompt, isSendEnabled else { return }
        queuedInitialPrompt = nil
        isInitialPromptSent = true
        isInitialPromptSubmitting = true
        sendMessage(text)
        isInitialPromptSubmitting = false
    }

    public func sendSuggestion(_ suggestion: Suggestion) { sendMessage(suggestion.prompt) }
    public func sendShortcut(_ shortcut: Suggestion) { sendMessage(shortcut.prompt) }
    public func close() { onOutput?(.close) }
    public func openHistory() { onOutput?(.openHistory) }
    public func startNewSession() {
        guard isNewSessionEnabled else { return }
        onOutput?(.startNewSession)
    }

    func reportUnauthorizableApproval() {
        errorMessage = copy.chat("chat.authorizationRequired")
    }

    func appendMessage(_ message: TanyaAIMessageItemViewModel) {
        messages.last?.consumeOptions()
        messages.append(message)
        trimMessages()
    }

    func trimMessages() {
        let overflow = messages.count - TanyaAIMessage.historyLimit
        if overflow > 0 { messages.removeFirst(overflow) }
        let identifiers = Set(messages.map(\.identifier))
        redirectedIdentifiers = redirectedIdentifiers.filter { identifiers.contains($0.value) }
        pendingSubmissions = pendingSubmissions.filter { identifiers.contains($0.value) }
    }

    deinit {
        repository.onEvent = nil
        repository.disconnect()
    }
}

public struct TanyaAIDraftRequest: Equatable {
    public let identifier = UUID()
    public let text: String
}
