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
    private(set) var channel: GroupChannel?
    /// True once a channel is being opened, so a burst of sends does not
    /// create several channels for one conversation.
    private var generation = 0
    private var isActive = false
    private var isOpeningChannel = false
    /// Messages typed before the channel finished opening.
    ///
    /// The package calls `connect()` and `send(...)` back to back, and opening
    /// a channel is a round trip - so without this the customer's first
    /// message is dropped in silence.
    private var queuedMessages: [(String, String)] = []

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

    /// Called when the feature appears, before anyone has spoken.
    ///
    /// The delegate is registered straight away, so a bot greeting or an agent
    /// reaching out arrives even if the customer never types. A *new*
    /// conversation still defers `createChannel` to the first message, so
    /// opening the chat and closing it again leaves no empty channel behind.
    func connect() {
        lock.lock()
        generation += 1
        let epoch = generation
        isActive = true
        lock.unlock()
        SendbirdChat.addChannelDelegate(self, identifier: delegateIdentifier)

        guard let existingChannelURL else {
            onEvent?(.connected)
            return
        }
        lock.lock()
        isOpeningChannel = true
        lock.unlock()

        GroupChannel.getChannel(url: existingChannelURL) { [weak self] channel, _ in
            guard let self, self.isCurrentGeneration(epoch) else { return }
            guard let channel else {
                // A stored channel that no longer exists must not dead-end the
                // customer: fall back to a new conversation.
                self.createChannel(epoch: epoch)
                return
            }
            self.adopt(channel, epoch: epoch)
        }
    }

    /// `requestIdentifier` is not sent: Sendbird will not echo it back, so
    /// correlating on it would be a promise this adapter cannot keep. The
    /// package falls back to the message identifier Sendbird supplies.
    @discardableResult
    func send(text: String, context: TanyaAIContext?, requestIdentifier: String) -> String? {
        lock.lock()
        let channel = self.channel
        let epoch = generation
        guard isActive else { lock.unlock(); return nil }
        var isChannelStartNeeded = false
        if channel == nil {
            queuedMessages.append((text, requestIdentifier))
            isChannelStartNeeded = !isOpeningChannel
            isOpeningChannel = true
        }
        lock.unlock()

        guard let channel else {
            if isChannelStartNeeded {
                createChannel(epoch: epoch)
            }
            return nil
        }
        sendNow(text, identifier: requestIdentifier, on: channel, epoch: epoch)
        return nil
    }

    private func sendNow(_ text: String, identifier: String, on channel: GroupChannel, epoch: Int) {
        channel.sendUserMessage(text) { [weak self] message, error in
            guard let self, self.isCurrentGeneration(epoch) else { return }
            if let error {
                self.onEvent?(.sendFailed(requestIdentifier: identifier, error: error))
            } else {
                self.onEvent?(
                    .sendSucceeded(
                        requestIdentifier: identifier,
                        messageIdentifier: message.map { String($0.messageId) }
                    ))
            }
        }
    }

    func disconnect() {
        // Deliberately NOT SendbirdChat.disconnect(). That is the
        // application's connection - closing the chat with it would take push
        // notifications and presence down for the whole app.
        SendbirdChat.removeChannelDelegate(forIdentifier: delegateIdentifier)
        lock.lock()
        generation += 1
        isActive = false
        channel = nil
        isOpeningChannel = false
        queuedMessages = []
        lock.unlock()
    }

    // MARK: - Channel

    private func createChannel(epoch: Int) {
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
            guard let self, self.isCurrentGeneration(epoch) else { return }
            guard let channel else {
                self.failToOpen(error ?? SendbirdAdapterError.channelUnavailable)
                return
            }
            self.adopt(channel, epoch: epoch)
        }
    }

    private func adopt(_ channel: GroupChannel, epoch: Int) {
        lock.lock()
        self.channel = channel
        isOpeningChannel = false
        let pending = queuedMessages
        queuedMessages = []
        lock.unlock()

        DispatchQueue.main.async { [weak self] in
            guard let self, self.isCurrentGeneration(epoch) else { return }
            self.onChannelReady?(channel.channelURL)
        }
        pending.forEach { sendNow($0.0, identifier: $0.1, on: channel, epoch: epoch) }
        // `.connected` goes last, once history has been read: it is what tells
        // the package the conversation is settled, so sending it first would
        // put a greeting on screen that history is about to replace.
        loadHistory(from: channel, epoch: epoch) { [weak self] in
            guard let self, self.isCurrentGeneration(epoch) else { return }
            self.onEvent?(.connected)
        }
    }

    /// The channel never opened. Ending the turn is what matters: a queued
    /// message with nowhere to go would otherwise leave the customer watching
    /// a typing indicator that never resolves.
    private func failToOpen(_ error: Error) {
        lock.lock()
        queuedMessages = []
        isOpeningChannel = false
        lock.unlock()
        onEvent?(.failed(error))
    }
    func isCurrentGeneration(_ epoch: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return isActive && generation == epoch
    }

}
