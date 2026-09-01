import Foundation
import TanyaAI
// import DolphinLiveChat   // the vendor module

// MARK: - Placeholders for the vendor SDK
//
// These four declarations stand in for the real SDK types. Delete them and
// import the vendor module instead; the adapter below is the only part that
// has to change, and only in the bodies of its delegate methods.

protocol VendorLiveChatClient: AnyObject {
    var delegate: VendorLiveChatClientDelegate? { get set }
    func connect(userToken: String)
    func sendMessage(_ text: String)
    func disconnect()
}

protocol VendorLiveChatClientDelegate: AnyObject {
    func clientDidConnect(_ client: VendorLiveChatClient)
    func client(
        _ client: VendorLiveChatClient,
        didReceive message: VendorMessage
    )
    func client(_ client: VendorLiveChatClient, isTyping: Bool)
    func client(_ client: VendorLiveChatClient, didFailWith error: Error)
    func client(
        _ client: VendorLiveChatClient,
        didDisconnectWith error: Error?
    )
}

struct VendorMessage {
    let identifier: String
    let text: String?
    /// Whatever the vendor calls its rich or custom payload.
    let payload: [String: Any]?
    /// True when this is the last part of the reply.
    let isFinal: Bool
}

// MARK: - Adapter

/// Makes a vendor live-chat SDK look like the transport the feature expects.
///
/// The package never imports the vendor: everything vendor-shaped stops here.
/// The job is a translation, and it has exactly four parts:
///
/// 1. connection lifecycle  -> `.connected` / `.disconnected` / `.failed`
/// 2. plain text            -> `.messageStarted` / `.messageDelta` /
///                             `.messageCompleted`
/// 3. the bot's rich payload -> `.structuredPayload`, which is what keeps the
///    typed cards working over a vendor channel
/// 4. a deeplink the channel pushes -> `.hostAction`
final class VendorChatSessionAdapter: NSObject,
                                      TanyaAIChatSession,
                                      VendorLiveChatClientDelegate {
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?

    private let client: VendorLiveChatClient
    private let userToken: String
    /// Identifiers already announced, so `messageStarted` is emitted once per
    /// reply even when the vendor delivers it in parts.
    private var startedMessages: Set<String> = []

    init(client: VendorLiveChatClient, userToken: String) {
        self.client = client
        self.userToken = userToken
        super.init()
        client.delegate = self
    }

    // MARK: TanyaAIChatSession

    func connect() {
        client.connect(userToken: userToken)
    }

    func send(text: String, requestIdentifier: String) {
        // Most live-chat SDKs do not echo a correlation id, so
        // requestIdentifier is unused here and the package falls back to the
        // vendor's own message identifier.
        client.sendMessage(text)
    }

    func disconnect() {
        client.disconnect()
    }

    // MARK: VendorLiveChatClientDelegate

    func clientDidConnect(_ client: VendorLiveChatClient) {
        onEvent?(.connected)
    }

    func client(
        _ client: VendorLiveChatClient,
        didReceive message: VendorMessage
    ) {
        if startedMessages.insert(message.identifier).inserted {
            onEvent?(.messageStarted(messageIdentifier: message.identifier))
        }

        if let text = message.text, text.isEmpty == false {
            onEvent?(
                .messageDelta(
                    messageIdentifier: message.identifier,
                    text: text
                )
            )
        }

        if let payload = message.payload {
            forward(payload)
        }

        if message.isFinal {
            startedMessages.remove(message.identifier)
            onEvent?(
                .messageCompleted(messageIdentifier: message.identifier)
            )
        }
    }

    func client(_ client: VendorLiveChatClient, isTyping: Bool) {
        onEvent?(.typing(isTyping))
    }

    func client(_ client: VendorLiveChatClient, didFailWith error: Error) {
        onEvent?(.failed(error))
    }

    func client(
        _ client: VendorLiveChatClient,
        didDisconnectWith error: Error?
    ) {
        startedMessages.removeAll()
        onEvent?(.disconnected(error))
    }

    // MARK: Payload translation

    /// The bot sends the same JSON it would have streamed over SSE, wrapped in
    /// whatever envelope the vendor uses. Agree two keys with the bot team and
    /// pass the inner object through untouched - do not re-model it here.
    ///
    /// Expected envelope:
    /// `{ "event": "content.actions", "data": { ... } }`
    ///
    /// A channel-pushed hand-off is the one special case: it opens something
    /// instead of rendering, so it becomes `.hostAction`.
    private func forward(_ payload: [String: Any]) {
        if let deeplink = payload["deeplink"] as? String {
            let identifier = payload["identifier"] as? String ?? "vendor-action"
            onEvent?(
                .hostAction(identifier: identifier, deeplink: deeplink)
            )
            return
        }

        guard let name = payload["event"] as? String,
              let data = payload["data"],
              let json = try? JSONSerialization.data(withJSONObject: data)
        else {
            return
        }
        onEvent?(.structuredPayload(name: name, json: json))
    }
}
