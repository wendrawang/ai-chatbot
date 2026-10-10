import DesignKit
import Foundation
import TanyaAIContracts
import TanyaAIDomain

/// Serializes vendor events and maps them into one main-queue channel stream.
public final class TanyaAISessionRepository: TanyaAIRepository {
    static let historyLimit = TanyaAIMessage.historyLimit
    private let session: TanyaAIChatSession
    private let eventsQueue = DispatchQueue(label: "TanyaAI.SessionEvents")
    let decoder = TanyaAIStreamEventDecoder()
    private var observer: ((TanyaAIStreamEvent) -> Void)?
    private var generation = 0
    private var isStarted = false
    private var isReady = false
    private var isHistoryReported = false
    private var pendingContent: [TanyaAIChatSessionEvent] = []
    private var context: TanyaAIContext?

    public var onEvent: ((TanyaAIStreamEvent) -> Void)? {
        get { eventsQueue.sync { observer } }
        set { eventsQueue.sync { observer = newValue } }
    }

    public init(session: TanyaAIChatSession, context: TanyaAIContext? = nil) {
        self.session = session
        self.context = context
    }

    public func connect() {
        let epoch: Int? = eventsQueue.sync {
            guard !isStarted else { return nil }
            generation += 1
            isStarted = true
            isReady = false
            isHistoryReported = false
            pendingContent.removeAll()
            emit(.connectionChanged(.connecting))
            return generation
        }
        guard let epoch else { return }
        session.onEvent = { [weak self] event in self?.enqueue(event, epoch: epoch) }
        session.connect()
    }

    @discardableResult
    public func sendMessage(text: String, requestIdentifier: String) -> String? {
        let submission = eventsQueue.sync { () -> (Bool, TanyaAIContext?) in
            if !isReady { emit(.sendFailed(requestIdentifier: requestIdentifier)) }
            return (isReady, context)
        }
        guard submission.0 else { return nil }
        return session.send(text: text, context: submission.1, requestIdentifier: requestIdentifier)
    }

    public func updateContext(_ context: TanyaAIContext?) {
        eventsQueue.sync { self.context = context }
    }

    public func disconnect() {
        session.onEvent = nil
        eventsQueue.sync {
            generation += 1
            isStarted = false
            isReady = false
            pendingContent.removeAll()
            emit(.connectionChanged(.closed))
        }
        session.disconnect()
    }

    deinit {
        session.onEvent = nil
        session.disconnect()
    }

    private func enqueue(_ event: TanyaAIChatSessionEvent, epoch: Int) {
        eventsQueue.async { [weak self] in
            guard let self, self.generation == epoch else { return }
            self.handle(event)
        }
    }

    private func handle(_ event: TanyaAIChatSessionEvent) {
        switch event {
        case .connected:
            if !isHistoryReported { emit(.history([])) }
            isHistoryReported = true
            isReady = true
            emit(.connectionChanged(.ready))
            flushPendingContent()
        case .failed, .disconnected:
            isReady = false
            if case .disconnected(nil) = event {
                emit(.connectionChanged(.closed))
            } else {
                emit(.connectionChanged(.failed))
            }
        case .historyFailed:
            isHistoryReported = true
            emit(.historyFailed)
            flushPendingContent()
        case .sendSucceeded(let identifier, let messageIdentifier):
            emit(.sendSucceeded(requestIdentifier: identifier, messageIdentifier: messageIdentifier))
        case .sendFailed(let identifier, _):
            emit(.sendFailed(requestIdentifier: identifier))
        default:
            receiveContent(event)
        }
    }

    private func receiveContent(_ event: TanyaAIChatSessionEvent) {
        if case .history(let messages) = event {
            isHistoryReported = true
            emit(.history(messages.suffix(Self.historyLimit).map(makeHistoryMessage)))
            flushPendingContent()
        } else if isHistoryReported {
            handleContent(event)
        } else {
            if pendingContent.count >= Self.historyLimit { pendingContent.removeFirst() }
            pendingContent.append(event)
        }
    }

    private func handleContent(_ event: TanyaAIChatSessionEvent) {
        switch event {
        case .messageStarted(let identifier):
            emit(.responseStarted(messageIdentifier: identifier))
        case .messageDelta(let identifier, let text):
            emit(.textDelta(messageIdentifier: identifier, text: text))
        case .messageCompleted(let identifier):
            emit(.responseCompleted(messageIdentifier: identifier))
        case .structuredPayload(let name, let json):
            emitStructured(name: name, json: json)
        case .typing(let isTyping):
            emit(.typing(isTyping))
        case .hostAction(let identifier, let deeplink):
            emit(.hostAction(Action(identifier: identifier, deeplink: deeplink)))
        default:
            break
        }
    }

    private func flushPendingContent() {
        let pending = pendingContent
        pendingContent.removeAll()
        pending.forEach(handleContent)
    }

    private func emitStructured(name: String, json: Data) {
        do {
            if let event = try decoder.decode(name: name, json: json) { emit(event) }
        } catch {
            emit(.content(messageIdentifier: UUID().uuidString, content: .unsupported(nil)))
        }
    }

    /// Called only on eventsQueue. Check the generation again at UI delivery.
    private func emit(_ event: TanyaAIStreamEvent) {
        let epoch = generation
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let callback = self.eventsQueue.sync {
                self.generation == epoch ? self.observer : nil
            }
            callback?(event)
        }
    }
}
