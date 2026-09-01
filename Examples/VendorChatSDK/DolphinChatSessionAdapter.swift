import Foundation
import TanyaAI
// import imi_dolphin_livechat_ios

/// Adapts the 3Dolphins Live Chat SDK to the transport the feature expects.
///
/// Two SDK facts are absorbed here, so nothing above this file knows either:
/// it reports through `NotificationCenter` rather than a delegate, and it
/// delivers whole messages rather than a token stream.
///
/// The package never imports `imi_dolphin_livechat_ios`.
final class DolphinChatSessionAdapter: NSObject, TanyaAIChatSession {
    /// Notification names, verbatim from the SDK documentation.
    enum Channel {
        static let message = "com.connector.notificationMessage"
        static let connectionStatus = "com.connector.connectionStatus"
        static let readMessage = "com.connector.notificationReadMessage"
        static let typingCondition = "com.connector.notificationTypingCondition"
    }

    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?

    private let connector: Connector
    private let profile: DolphinProfile
    private let configuration: Configuration
    private let mapper: DolphinMessageMapper
    private let isConnected: (Int) -> Bool
    private var isObserving = false

    /// - Parameters:
    ///   - mapper: how to read a `DolphinMessage`. Kept out of the adapter
    ///     because the field names live in the framework header, not in the
    ///     public docs.
    ///   - isConnected: which raw value from `com.connector.connectionStatus`
    ///     means connected. Verify against the header; the default assumes 1.
    init(
        connector: Connector,
        profile: DolphinProfile,
        configuration: Configuration,
        mapper: DolphinMessageMapper,
        isConnected: @escaping (Int) -> Bool = { $0 == 1 }
    ) {
        self.connector = connector
        self.profile = profile
        self.configuration = configuration
        self.mapper = mapper
        self.isConnected = isConnected
        super.init()
    }

    deinit {
        stopObserving()
    }

    // MARK: - TanyaAIChatSession

    func connect() {
        startObserving()
        connector.setupConnection(
            baseUrl: configuration.baseUrl,
            clientId: configuration.clientId,
            clientSecrect: configuration.clientSecrect
        )
        connector.enableGetQueue(isEnable: configuration.enableGetQueue)
        connector.constructConnector(profile: profile)
    }

    func send(text: String, requestIdentifier: String) {
        // The SDK echoes no correlation id, so requestIdentifier is unused:
        // the turn ends when the next inbound message completes.
        connector.onSendMessage(
            messages: text,
            dataUser: configuration.dataUser
        )
    }

    func disconnect() {
        stopObserving()
        // The public docs list no teardown call. If the header exposes one,
        // call it here; dropping the observers is what stops the feature from
        // reacting after it is released.
        onEvent?(.disconnected(nil))
    }

    // MARK: - Notifications

    private func startObserving() {
        guard isObserving == false else {
            return
        }
        isObserving = true
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(didReceiveMessage(_:)),
            name: Notification.Name(Channel.message),
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(didUpdateConnectionStatus(_:)),
            name: Notification.Name(Channel.connectionStatus),
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(didUpdateTypingCondition(_:)),
            name: Notification.Name(Channel.typingCondition),
            object: nil
        )
        // com.connector.notificationReadMessage carries delivery receipts,
        // which this UI does not render. Left unobserved on purpose.
    }

    private func stopObserving() {
        guard isObserving else {
            return
        }
        isObserving = false
        NotificationCenter.default.removeObserver(self)
    }

    /// One inbound message is one complete reply: the SDK does not stream
    /// tokens. The message announces itself, delivers its content, and ends
    /// the turn, so no "last message" marker has to be agreed with the bot.
    @objc private func didReceiveMessage(_ notification: NSNotification) {
        guard let message = notification.object as? DolphinMessage else {
            return
        }
        let identifier = mapper.identifier(message)
        onEvent?(.typing(false))

        if let payload = mapper.payload(message),
           let structured = event(from: payload) {
            onEvent?(structured)
        } else if let text = mapper.text(message), text.isEmpty == false {
            if let structured = event(fromJSONText: text) {
                onEvent?(structured)
            } else {
                onEvent?(.messageStarted(messageIdentifier: identifier))
                onEvent?(
                    .messageDelta(messageIdentifier: identifier, text: text)
                )
            }
        }

        onEvent?(.messageCompleted(messageIdentifier: identifier))
    }

    @objc private func didUpdateConnectionStatus(
        _ notification: NSNotification
    ) {
        guard let status = notification.object as? Int else {
            return
        }
        onEvent?(isConnected(status) ? .connected : .disconnected(nil))
    }

    /// The documented handler receives no payload, so anything truthy reads as
    /// "composing" and the next inbound message clears it.
    @objc private func didUpdateTypingCondition(
        _ notification: NSNotification
    ) {
        let isTyping: Bool
        switch notification.object {
        case let value as Bool:
            isTyping = value
        case let value as Int:
            isTyping = value != 0
        default:
            isTyping = true
        }
        onEvent?(.typing(isTyping))
    }

    // MARK: - Payload translation

    /// The bot sends the same JSON it would have streamed over SSE, in an
    /// envelope of two keys, and `data` is passed through untouched:
    ///
    ///     { "event": "content.actions", "data": { ... } }
    ///
    /// A payload carrying `deeplink` is a hand-off the channel asked for: it
    /// opens something instead of rendering, and leaves through the host's
    /// `onAction` handler exactly like a button on a card.
    private func event(
        from payload: [String: Any]
    ) -> TanyaAIChatSessionEvent? {
        if let deeplink = payload["deeplink"] as? String {
            let identifier = payload["identifier"] as? String ?? "vendor-action"
            return .hostAction(identifier: identifier, deeplink: deeplink)
        }
        guard let name = payload["event"] as? String,
              let data = payload["data"],
              let json = try? JSONSerialization.data(withJSONObject: data)
        else {
            return nil
        }
        return .structuredPayload(name: name, json: json)
    }

    /// Fallback for deployments where the bot cannot attach a rich payload and
    /// sends the envelope as message text instead.
    private func event(fromJSONText text: String) -> TanyaAIChatSessionEvent? {
        guard text.hasPrefix("{"),
              let data = text.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              let payload = object as? [String: Any] else {
            return nil
        }
        return event(from: payload)
    }
}
