import Foundation
import TanyaAIContracts

/// A controllable session double for tests and the Figma UI demo.
public final class MockTanyaAIChatSession: TanyaAIChatSession {
    public var onEvent: ((TanyaAIChatSessionEvent) -> Void)?

    /// Every text passed to `send`, in order. Useful in tests.
    public private(set) var sentTexts: [String] = []
    /// The context attached to each sent message, in the same order.
    public private(set) var sentContexts: [TanyaAIContext?] = []
    public private(set) var isConnected = false

    private var generation = 0
    private let reply: (String) -> [TanyaAIChatSessionEvent]
    private let callbackQueue: DispatchQueue
    private let stepDelay: TimeInterval

    /// - Parameters:
    ///   - callbackQueue: queue the events are delivered on. The package hops
    ///     to the main queue itself, so any queue is valid.
    ///   - stepDelay: pause between events, so streaming is visible in a demo.
    ///   - reply: the events to emit for a given customer message.
    public init(
        callbackQueue: DispatchQueue = .main,
        stepDelay: TimeInterval = 0.05,
        reply: @escaping (String) -> [TanyaAIChatSessionEvent]
    ) {
        self.callbackQueue = callbackQueue
        self.stepDelay = stepDelay
        self.reply = reply
    }

    public func connect() {
        generation += 1
        isConnected = true
        emit([.connected], startingAt: 0)
    }

    @discardableResult
    public func send(
        text: String,
        context: TanyaAIContext?,
        requestIdentifier: String
    ) -> String? {
        guard isConnected else { return nil }
        let remoteIdentifier = UUID().uuidString
        sentTexts.append(text)
        sentContexts.append(context)
        emit([.sendSucceeded(requestIdentifier: requestIdentifier, messageIdentifier: remoteIdentifier)], startingAt: 0)
        emit(reply(text), startingAt: 1)
        return remoteIdentifier
    }

    public func disconnect() {
        generation += 1
        isConnected = false
    }

    private func emit(
        _ events: [TanyaAIChatSessionEvent],
        startingAt offset: Int
    ) {
        let epoch = generation
        for (index, event) in events.enumerated() {
            let delay = stepDelay * Double(index + offset)
            callbackQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self, self.generation == epoch else { return }
                self.onEvent?(event)
            }
        }
    }
}
