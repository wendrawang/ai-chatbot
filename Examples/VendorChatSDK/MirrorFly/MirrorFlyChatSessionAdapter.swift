import Foundation
import MirrorFlySDK
import TanyaAI

/// Drives the chat from a MirrorFly one-to-one conversation.
///
/// The package never imports MirrorFly. This adapter is the whole of the
/// translation: MirrorFly's callbacks in, `TanyaAIChatSessionEvent` out.
///
/// ## What belongs here, and what does not
///
/// `ChatManager.initializeSDK` and `ChatManager.registerApiService` belong to
/// the application, not to a chat screen - see the README next to this file.
/// This object owns only the conversation with one bot JID.
///
/// ## Names to check against the pod
///
/// MirrorFly's public docs do not spell out every symbol this adapter needs.
/// Lines marked `CHECK:` are the ones to confirm against the installed SDK's
/// headers before the first run. Everything else is from the quick-start and
/// retrieve-messages pages.
final class MirrorFlyChatSessionAdapter: NSObject, TanyaAIChatSession {
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?

    /// How many past messages a reopened conversation shows.
    static let historyLimit = 50

    private let botJID: String
    private let currentUserJID: String

    /// - Parameters:
    ///   - botJID: the bot's JID, from `FlyUtils.getJid(BOT_USER_NAME)`.
    ///   - currentUserJID: this customer's JID, as returned by
    ///     `registerApiService` in `flyData["userJid"]`. Needed to tell the
    ///     customer's own past messages from the bot's.
    init(botJID: String, currentUserJID: String) {
        self.botJID = botJID
        self.currentUserJID = currentUserJID
        super.init()
    }

    // MARK: - TanyaAIChatSession

    /// Called when the feature appears, before anyone has spoken.
    ///
    /// There is no channel to create: MirrorFly addresses a JID directly, so
    /// unlike the Sendbird adapter nothing has to be queued while a channel
    /// opens, and the first message can go out immediately.
    ///
    /// `.connected` goes last, after history, because it is what tells the
    /// package the conversation has settled. Sending it first would put a
    /// greeting on screen that history is about to replace.
    func connect() {
        // CHECK: one delegate per app, not a registry. See the README - this
        // steals the delegate from anything else that set it.
        ChatManager.shared.messageEventsDelegate = self
        reportHistory()
        onEvent?(.connected)
    }

    /// `requestIdentifier` is not sent: MirrorFly will not echo it back, so
    /// correlating on it would be a promise this adapter cannot keep. The
    /// package falls back to the message identifier MirrorFly supplies.
    ///
    /// `context` is where the chat was opened from. It must never become
    /// visible chat text; it belongs in the message's metadata field, which is
    /// the one symbol here worth confirming first.
    func send(text: String, context: TanyaAIContext?, requestIdentifier: String) {
        var message = TextMessage()
        message.toId = botJID
        message.messageText = text
        // CHECK: the metadata field's name. The docs advertise "Message By
        // MetaData" without naming the property on TextMessage. Until it is
        // confirmed, context is dropped rather than leaked into the message
        // body - a wrong guess here would show routing data to the customer.
        FlyMessenger.sendTextMessage(messageParams: message) { [weak self] isSuccess, error, _ in
            guard isSuccess == false else {
                return
            }
            self?.onEvent?(.failed(error ?? MirrorFlyAdapterError.sendFailed))
        }
    }

    func disconnect() {
        // Deliberately NOT a logout. That is the application's session -
        // closing the chat with it would take the whole app's messaging down.
        guard ChatManager.shared.messageEventsDelegate === self else {
            return
        }
        ChatManager.shared.messageEventsDelegate = nil
    }
}

// MARK: - Incoming messages

extension MirrorFlyChatSessionAdapter: MessageEventsDelegate {
    func onMessageReceived(message: ChatMessage, chatJid: String) {
        guard chatJid == botJID else {
            return
        }
        guard let event = makeEvents(for: message) else {
            return
        }
        event.forEach { onEvent?($0) }
    }

    /// Turns one delivered message into the events the package expects.
    ///
    /// MirrorFly delivers a whole message rather than a stream, so a plain
    /// reply is one delta between a start and a completion.
    private func makeEvents(
        for message: ChatMessage
    ) -> [TanyaAIChatSessionEvent]? {
        // CHECK: the identifier property. `messageId` is the name used
        // throughout the docs; some builds expose it as `messageChatId`.
        let identifier = message.messageId

        if let card = structuredPayload(in: message) {
            // A card is a whole reply, so the turn ends here. Without the
            // completion the customer is left watching a typing indicator that
            // never resolves and a send button stuck as Stop.
            return [
                .structuredPayload(name: card.name, json: card.json),
                .messageCompleted(messageIdentifier: identifier)
            ]
        }

        let text = message.messageTextContent
        guard text.isEmpty == false else {
            return nil
        }
        return [
            .messageStarted(messageIdentifier: identifier),
            .messageDelta(messageIdentifier: identifier, text: text),
            .messageCompleted(messageIdentifier: identifier)
        ]
    }
}

// MARK: - Typed cards

extension MirrorFlyChatSessionAdapter {
    /// A typed card: the bot puts the package's own event JSON into the
    /// message's metadata, and this passes it through untouched.
    ///
    /// The shape is the one in `docs/BUBBLE_SCHEMA.md` - a name such as
    /// `content.approval` and that event's `data` object. Sendbird carries
    /// these in `custom_type` + `data`; MirrorFly's equivalent is its message
    /// metadata, so this is the one function to rewrite once that field is
    /// confirmed.
    func structuredPayload(
        in message: ChatMessage
    ) -> (name: String, json: Data)? {
        // CHECK: metadata accessor and its type. Written against a
        // [String: String] shape; adjust the two casts if it differs.
        guard let metadata = message.metaData as? [String: String],
              let name = metadata["type"],
              name.hasPrefix("content."),
              let json = metadata["data"]?.data(using: .utf8),
              json.isEmpty == false else {
            return nil
        }
        return (name, json)
    }
}

// MARK: - History

extension MirrorFlyChatSessionAdapter {
    /// Reads the conversation back, so reopening the chat is not an empty
    /// screen.
    ///
    /// `getMessagesOf` reads the local store and returns synchronously, so
    /// unlike the Sendbird adapter there is no completion to thread through
    /// `connect()`. If a future version makes this a round trip, move the
    /// `.connected` above into its callback rather than leaving it where it
    /// is - that ordering is what stops the greeting flashing.
    func reportHistory() {
        let messages = FlyMessenger.getMessagesOf(jid: botJID)
        guard messages.isEmpty == false else {
            return
        }
        let restored = messages
            .suffix(Self.historyLimit)
            .compactMap(makeHistoryMessage)
        guard restored.isEmpty == false else {
            return
        }
        onEvent?(.history(restored))
    }

    func makeHistoryMessage(
        _ message: ChatMessage
    ) -> TanyaAIChatSessionMessage? {
        // CHECK: how a message says who sent it. `senderJid` is the likely
        // name; `isMessageSentByMe` also appears in MirrorFly's samples and
        // would be simpler if the pod exposes it.
        let isCustomer = message.senderJid == currentUserJID
        let author: TanyaAIChatSessionMessage.Author =
            isCustomer ? .customer : .assistant
        let identifier = message.messageId
        let text = message.messageTextContent

        if let card = structuredPayload(in: message) {
            return TanyaAIChatSessionMessage(
                identifier: identifier,
                author: author,
                text: text,
                structuredName: card.name,
                structuredJSON: card.json
            )
        }
        guard text.isEmpty == false else {
            return nil
        }
        return TanyaAIChatSessionMessage(
            identifier: identifier,
            author: author,
            text: text
        )
    }
}

enum MirrorFlyAdapterError: LocalizedError {
    case sendFailed

    var errorDescription: String? {
        "The message could not be sent."
    }
}
