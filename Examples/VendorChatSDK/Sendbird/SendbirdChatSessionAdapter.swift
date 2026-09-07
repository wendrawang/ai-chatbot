import Foundation
import SendbirdChatSDK
import TanyaAI

/// Drives the chat from a Sendbird group channel.
///
/// The package never imports Sendbird. This adapter is the whole of the
/// translation: Sendbird's callbacks in, `TanyaAIChatSessionEvent` out.
///
/// ## What belongs here, and what does not
///
/// Only the channel is this object's business. `SendbirdChat.initialize` and
/// `SendbirdChat.connect` belong to the application, not to a chat screen -
/// see the README next to this file for why, and for the trap in putting
/// `SendbirdChat.disconnect()` in `disconnect()`.
final class SendbirdChatSessionAdapter: NSObject, TanyaAIChatSession {
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?

    private let botUserId: String
    private let existingChannelURL: String?
    private let delegateIdentifier = "tanyaai.session.\(UUID().uuidString)"
    private let lock = NSLock()
    private var channel: GroupChannel?
    /// Messages typed before the channel finished opening.
    ///
    /// The package calls `connect()` and `send(...)` back to back, and opening
    /// a channel is a round trip - so without this the customer's first
    /// message is dropped in silence.
    private var queuedMessages: [String] = []

    /// Reports the channel the session settled on, so the host can store it
    /// and pass it back as `channelURL` to continue this conversation later.
    var onChannelReady: ((String) -> Void)?

    /// - Parameters:
    ///   - botUserId: the bot's Sendbird user id, added as a channel member.
    ///   - channelURL: nil starts a new conversation; a stored URL continues
    ///     an existing one. Which of the two is a product decision - opening
    ///     from the history screen continues, the entry point starts fresh.
    init(botUserId: String, channelURL: String? = nil) {
        self.botUserId = botUserId
        self.existingChannelURL = channelURL
        super.init()
    }

    // MARK: - TanyaAIChatSession

    func connect() {
        SendbirdChat.addChannelDelegate(self, identifier: delegateIdentifier)

        guard let existingChannelURL else {
            createChannel()
            return
        }
        GroupChannel.getChannel(url: existingChannelURL) { [weak self] channel, error in
            guard let channel else {
                // A stored channel that no longer exists must not dead-end the
                // customer: fall back to a new conversation.
                self?.createChannel()
                return
            }
            self?.adopt(channel)
        }
    }

    /// `requestIdentifier` is not sent: Sendbird will not echo it back, so
    /// correlating on it would be a promise this adapter cannot keep. The
    /// package falls back to the message identifier Sendbird supplies.
    func send(text: String, context: TanyaAIContext?, requestIdentifier: String) {
        lock.lock()
        let channel = self.channel
        if channel == nil {
            queuedMessages.append(text)
        }
        lock.unlock()

        guard let channel else {
            return
        }
        sendNow(text, on: channel)
    }

    private func sendNow(_ text: String, on channel: GroupChannel) {
        channel.sendUserMessage(text) { [weak self] _, error in
            if let error {
                self?.onEvent?(.failed(error))
            }
        }
    }

    func disconnect() {
        // Deliberately NOT SendbirdChat.disconnect(). That is the
        // application's connection - closing the chat with it would take push
        // notifications and presence down for the whole app.
        SendbirdChat.removeChannelDelegate(forIdentifier: delegateIdentifier)
        lock.lock()
        channel = nil
        queuedMessages = []
        lock.unlock()
    }

    // MARK: - Channel

    private func createChannel() {
        let params = GroupChannelCreateParams()
        params.name = "Tanya AI"
        // The sample app only ever adds `[User]` objects, which this adapter
        // does not have - it is given ids. Check this line against the SDK
        // header: `userIds`, `addUserIds(_:)`, and `addUsers(_:)` have all
        // existed across versions.
        var memberIds = [botUserId]
        if let currentUserId = SendbirdChat.getCurrentUser()?.userId {
            memberIds.append(currentUserId)
        }
        params.userIds = memberIds
        GroupChannel.createChannel(params: params) { [weak self] channel, error in
            guard let channel else {
                self?.failToOpen(error ?? SendbirdAdapterError.channelUnavailable)
                return
            }
            self?.adopt(channel)
        }
    }

    private func adopt(_ channel: GroupChannel) {
        lock.lock()
        self.channel = channel
        let pending = queuedMessages
        queuedMessages = []
        lock.unlock()

        onChannelReady?(channel.channelURL)
        onEvent?(.connected)
        pending.forEach { sendNow($0, on: channel) }
    }

    /// The channel never opened. Ending the turn is what matters: a queued
    /// message with nowhere to go would otherwise leave the customer watching
    /// a typing indicator that never resolves.
    private func failToOpen(_ error: Error) {
        lock.lock()
        queuedMessages = []
        lock.unlock()
        onEvent?(.failed(error))
    }
}

// MARK: - Incoming messages

/// Both protocols, deliberately.
///
/// `channel(_:didReceive:)` is declared on `BaseChannelDelegate`, and
/// `channelDidUpdateTypingStatus` on `GroupChannelDelegate`. Conforming to
/// only the second one risks never being handed an incoming message - which
/// fails silently, as a chat where the bot never answers.
extension SendbirdChatSessionAdapter: BaseChannelDelegate, GroupChannelDelegate {
    func channel(_ sender: BaseChannel, didReceive message: BaseMessage) {
        guard sender.channelURL == channel?.channelURL else {
            return
        }
        // The customer's own message comes back over the channel too.
        guard message.sender?.userId != SendbirdChat.getCurrentUser()?.userId else {
            return
        }

        let identifier = String(message.messageId)

        // A typed card: the bot puts the same JSON it would have streamed over
        // SSE into the message, and this passes it through untouched.
        if let name = message.customType,
           name.hasPrefix("content."),
           let json = message.data.data(using: .utf8),
           json.isEmpty == false {
            onEvent?(.structuredPayload(name: name, json: json))
            return
        }

        guard let text = (message as? UserMessage)?.message else {
            return
        }
        // Sendbird delivers a whole message, so one delta then completion.
        onEvent?(.messageStarted(messageIdentifier: identifier))
        onEvent?(.messageDelta(messageIdentifier: identifier, text: text))
        onEvent?(.messageCompleted(messageIdentifier: identifier))
    }

    func channelDidUpdateTypingStatus(_ sender: GroupChannel) {
        guard sender.channelURL == channel?.channelURL else {
            return
        }
        onEvent?(.typing(sender.getTypingUsers()?.isEmpty == false))
    }
}

enum SendbirdAdapterError: Error {
    case channelUnavailable
    case notSignedIn
}
