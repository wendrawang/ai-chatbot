import Foundation
import TanyaAIContracts
import TanyaAIDomain

/// Drives the chat from a vendor SDK session instead of an SSE request.
///
/// Same `TanyaAIRepository` contract as the streaming version, so nothing
/// above this layer knows which transport is in use. Two differences are
/// handled here:
///
/// - a session has no per-request completion, so a turn ends on
///   `messageCompleted`, `failed`, or an unexpected `disconnected`;
/// - a session delivers messages nobody asked for, which are forwarded to the
///   unsolicited observer rather than to the turn in flight.
public final class TanyaAISessionRepository: TanyaAIRepository {
    private let session: TanyaAIChatSession
    private let decoder = TanyaAIStreamEventDecoder()
    private let lock = NSLock()
    private var activeTurn: Turn?
    private var unsolicitedObserver: ((TanyaAIStreamEvent) -> Void)?
    private var hasConnected = false
    private var context: TanyaAIContext?

    public init(
        session: TanyaAIChatSession,
        context: TanyaAIContext? = nil
    ) {
        self.session = session
        self.context = context
        session.onEvent = { [weak self] event in
            self?.handle(event)
        }
    }

    deinit {
        session.onEvent = nil
        session.disconnect()
    }

    @discardableResult
    public func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        let requestIdentifier = UUID().uuidString
        let turn = Turn(
            identifier: requestIdentifier,
            onEvent: onEvent,
            completion: completion
        )

        lock.lock()
        let needsConnect = !hasConnected
        hasConnected = true
        activeTurn = turn
        let context = self.context
        lock.unlock()

        if needsConnect {
            session.connect()
        }
        session.send(
            text: text,
            context: context,
            requestIdentifier: requestIdentifier
        )
        return TurnCancellable { [weak self] in
            self?.finishTurn(identifier: requestIdentifier, result: nil)
        }
    }

    public func updateContext(_ context: TanyaAIContext?) {
        lock.lock()
        self.context = context
        lock.unlock()
    }

    /// Events that arrive outside a turn: an agent replying on their own, a
    /// typing indicator between turns, a hand-off pushed by the channel.
    public func observeUnsolicitedEvents(
        _ onEvent: @escaping (TanyaAIStreamEvent) -> Void
    ) {
        lock.lock()
        unsolicitedObserver = onEvent
        lock.unlock()
    }

    // MARK: - Session events

    private func handle(_ event: TanyaAIChatSessionEvent) {
        switch event {
        case .connected:
            break
        case .disconnected(let error):
            guard let error else {
                return
            }
            finishTurn(identifier: nil, result: .failure(error))
        case .failed(let error):
            finishTurn(identifier: nil, result: .failure(error))
        case .messageStarted(let identifier):
            emit(.responseStarted(messageIdentifier: identifier))
        case .messageDelta(let identifier, let text):
            emit(.textDelta(messageIdentifier: identifier, text: text))
        case .messageCompleted(let identifier):
            emit(.responseCompleted(messageIdentifier: identifier))
            finishTurn(identifier: nil, result: .success(()))
        case .structuredPayload(let name, let json):
            emitStructured(name: name, json: json)
        case .typing(let isTyping):
            emit(.typing(isTyping))
        case .hostAction(let identifier, let deeplink):
            emit(
                .hostAction(
                    TanyaAIAction(identifier: identifier, deeplink: deeplink)
                )
            )
        }
    }

    /// A malformed card must not tear down the channel: it degrades to the
    /// unsupported fallback, exactly as it would over SSE.
    private func emitStructured(name: String, json: Data) {
        do {
            guard let event = try decoder.decode(
                TanyaAISSEEvent(name: name, data: json)
            ) else {
                return
            }
            emit(event)
        } catch {
            emit(
                .content(
                    messageIdentifier: UUID().uuidString,
                    content: .unsupported(
                        "This content requires a newer app version."
                    )
                )
            )
        }
    }

    private func emit(_ event: TanyaAIStreamEvent) {
        lock.lock()
        let turn = activeTurn
        let observer = unsolicitedObserver
        lock.unlock()

        if let turn {
            turn.onEvent(event)
        } else {
            observer?(event)
        }
    }

    private func finishTurn(
        identifier: String?,
        result: Result<Void, Error>?
    ) {
        lock.lock()
        guard let turn = activeTurn,
              identifier == nil || identifier == turn.identifier else {
            lock.unlock()
            return
        }
        activeTurn = nil
        lock.unlock()

        if let result {
            turn.completion(result)
        }
    }

    private struct Turn {
        let identifier: String
        let onEvent: (TanyaAIStreamEvent) -> Void
        let completion: (Result<Void, Error>) -> Void
    }
}

private final class TurnCancellable: TanyaAICancellable {
    private let action: () -> Void

    init(_ action: @escaping () -> Void) {
        self.action = action
    }

    func cancel() {
        action()
    }
}
