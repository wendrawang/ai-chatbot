import Foundation
import TanyaAIContracts

/// Stands in for a vendor chat SDK session.
///
/// Lets a host build and run the whole feature - typed cards, hand-off, agent
/// typing - before the real SDK is wired in:
///
/// ```swift
/// let dependencies = TanyaAIDependencies(
///     chatSession: MockTanyaAIChatSession.demo(
///         deeplink: "ocbcid://mobile?type=transfer"
///     ),
///     authorizationService: MockTanyaAIAuthorizationService(),
///     theme: .sandbox
/// )
/// ```
public final class MockTanyaAIChatSession: TanyaAIChatSession {
    public var onEvent: ((TanyaAIChatSessionEvent) -> Void)?

    /// Every text passed to `send`, in order. Useful in tests.
    public private(set) var sentTexts: [String] = []
    public private(set) var isConnected = false

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
        isConnected = true
        emit([.connected], startingAt: 0)
    }

    public func send(text: String, requestIdentifier: String) {
        sentTexts.append(text)
        emit(reply(text), startingAt: 1)
    }

    public func disconnect() {
        isConnected = false
        emit([.disconnected(nil)], startingAt: 0)
    }

    private func emit(
        _ events: [TanyaAIChatSessionEvent],
        startingAt offset: Int
    ) {
        for (index, event) in events.enumerated() {
            let delay = stepDelay * Double(index + offset)
            callbackQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.onEvent?(event)
            }
        }
    }
}

public extension MockTanyaAIChatSession {
    /// A reply that exercises every path a session transport adds: typing,
    /// streamed text, a typed card carrying the host's own deeplink, and a
    /// hand-off pushed by the channel itself.
    static func demo(
        deeplink: String,
        callbackQueue: DispatchQueue = .main,
        stepDelay: TimeInterval = 0.05
    ) -> MockTanyaAIChatSession {
        MockTanyaAIChatSession(
            callbackQueue: callbackQueue,
            stepDelay: stepDelay
        ) { text in
            let identifier = "vendor-\(UUID().uuidString.prefix(8))"
            var events: [TanyaAIChatSessionEvent] = [
                .typing(true),
                .messageStarted(messageIdentifier: identifier),
                .messageDelta(
                    messageIdentifier: identifier,
                    text: "Reply from the vendor channel for: \(text)"
                ),
                .typing(false)
            ]
            if let json = actionCardJSON(
                messageIdentifier: "\(identifier)-card",
                deeplink: deeplink
            ) {
                events.append(
                    .structuredPayload(name: "content.actions", json: json)
                )
            }
            events.append(
                .messageCompleted(messageIdentifier: identifier)
            )
            return events
        }
    }

    /// A channel-sourced hand-off: no card is rendered, the deeplink goes
    /// straight to the host.
    static func handoffOnly(
        deeplink: String,
        callbackQueue: DispatchQueue = .main,
        stepDelay: TimeInterval = 0.05
    ) -> MockTanyaAIChatSession {
        MockTanyaAIChatSession(
            callbackQueue: callbackQueue,
            stepDelay: stepDelay
        ) { _ in
            let identifier = "vendor-handoff"
            return [
                .messageStarted(messageIdentifier: identifier),
                .messageDelta(
                    messageIdentifier: identifier,
                    text: "Opening the existing screen for you."
                ),
                .hostAction(
                    identifier: "vendor-handoff",
                    deeplink: deeplink
                ),
                .messageCompleted(messageIdentifier: identifier)
            ]
        }
    }

    private static func actionCardJSON(
        messageIdentifier: String,
        deeplink: String
    ) -> Data? {
        let payload: [String: Any] = [
            "messageIdentifier": messageIdentifier,
            "title": "Continue in the app",
            "actions": [
                [
                    "title": "Open the existing screen",
                    "style": "primary",
                    "action": [
                        "identifier": "vendor-open",
                        "deeplink": deeplink
                    ]
                ]
            ]
        ]
        return try? JSONSerialization.data(
            withJSONObject: payload,
            options: [.sortedKeys]
        )
    }
}
