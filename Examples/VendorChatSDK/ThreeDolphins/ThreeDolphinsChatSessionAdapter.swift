import Foundation
import TanyaAI
import imi_dolphin_livechat_ios

/// Drives the chat from a 3Dolphins LiveChat session.
///
/// The package never imports 3Dolphins. This adapter is the whole of the
/// translation: the SDK's notifications in, `TanyaAIChatSessionEvent` out.
///
/// ## What belongs here, and what does not
///
/// `Connector.shared.setupConnection` belongs to the application - it carries
/// credentials and is called once. This object owns one conversation:
/// `constructConnector` when the feature appears, `endActiveSession` when it
/// goes away.
///
/// ## Names to check against the pod
///
/// 3Dolphins' public docs describe the call surface but not its data. Lines
/// marked `CHECK:` are guesses at shapes the documentation never shows -
/// `DolphinMessage`'s properties above all. Read `Connector.swift` and
/// `DolphinMessage.swift` from the pod before the first run; more of this file
/// is unverified than verified.
final class ThreeDolphinsChatSessionAdapter: NSObject, TanyaAIChatSession {
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?

    private let profile: DolphinProfile
    let botId: String?
    /// The reply being streamed. 3Dolphins delivers a token at a time, so a
    /// turn is open from the first chunk until the SDK says it is done.
    private var streamingIdentifier: String?
    private var isConnectionReported = false

    /// - Parameters:
    ///   - profile: who is chatting. Built by the host from the signed-in
    ///     customer, never invented here.
    ///   - botId: which bot answers, when the account has more than one.
    init(profile: DolphinProfile, botId: String? = nil) {
        self.profile = profile
        self.botId = botId
        super.init()
    }

    // MARK: - TanyaAIChatSession

    /// Called when the feature appears, before anyone has spoken.
    ///
    /// Observers go on first. The socket reports its state through
    /// `NotificationCenter`, and a status that arrives before anyone is
    /// listening is simply lost - there is no way to ask for it later.
    func connect() {
        observe(notificationMessage, #selector(messageArrived(_:)))
        observe(notificationConnectionStatus, #selector(statusChanged(_:)))
        Connector.shared.constructConnector(profile: profile)
    }

    /// `requestIdentifier` is not sent: 3Dolphins will not echo it back, so
    /// correlating on it would be a promise this adapter cannot keep.
    ///
    /// `context` is where the chat was opened from. It must never become
    /// visible chat text, and `dataUser` is the only field that might carry
    /// it - see the README for why that is not yet a safe assumption.
    func send(text: String, context: TanyaAIContext?, requestIdentifier: String) {
        Connector.shared.onSendMessage(messages: text)
    }

    func disconnect() {
        // A disconnected session must stop receiving events before deinit.
        // swiftlint:disable:next notification_center_detachment
        NotificationCenter.default.removeObserver(self)
        // This ends the conversation, not the app's credentials: the token
        // from `setupConnection` survives for the next presentation.
        Connector.shared.endActiveSession()
        streamingIdentifier = nil
        isConnectionReported = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Socket state

    /// The SDK reports six states as a bare integer. Only two of them mean
    /// anything to the package: open for business, and gone.
    @objc private func statusChanged(_ notification: Notification) {
        // CHECK: how the code is carried. `object` is the shape the Chat UI
        // example implies; it may instead be a key in `userInfo`.
        guard let status = notification.object as? Int else {
            return
        }
        switch status {
        case 2:
            reportConnected()
        case 4, 5:
            onEvent?(.disconnected(nil))
        case 6:
            onEvent?(.failed(ThreeDolphinsAdapterError.attachmentRejected))
        default:
            // 1 connecting, 3 reconnecting: in flight, nothing to report.
            break
        }
    }

    /// `.connected` goes last, once history has been read: it is what tells
    /// the package the conversation is settled, so sending it first would put
    /// a greeting on screen that history is about to replace.
    ///
    /// Reconnects raise status 2 again; the guard keeps the screen from being
    /// rebuilt underneath the customer each time the socket blinks.
    private func reportConnected() {
        guard isConnectionReported == false else {
            return
        }
        isConnectionReported = true
        loadHistory { [weak self] in
            self?.onEvent?(.connected)
        }
    }

    private func observe(_ name: String, _ selector: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: selector,
            name: Notification.Name(rawValue: name),
            object: nil
        )
    }
}

// MARK: - Incoming messages

extension ThreeDolphinsChatSessionAdapter {
    @objc func messageArrived(_ notification: Notification) {
        // CHECK: the payload's type and where it hangs. `DolphinMessage` is
        // named in the docs as the message model, but neither its properties
        // nor the notification's shape are published.
        guard let message = notification.object as? DolphinMessage else {
            return
        }
        deliver(message)
    }

    /// Turns one delivered message into the events the package expects.
    ///
    /// A streamed reply is a run of deltas between one start and one
    /// completion, which is the shape the package was built for - it predates
    /// the Sendbird adapter, where a whole message had to be faked as a single
    /// delta.
    private func deliver(_ message: DolphinMessage) {
        // CHECK: every property read below.
        let identifier = message.id ?? UUID().uuidString
        let text = message.text ?? ""

        if let card = structuredPayload(in: message) {
            endStreamIfOpen()
            onEvent?(.structuredPayload(name: card.name, json: card.json))
            onEvent?(.messageCompleted(messageIdentifier: identifier))
            return
        }

        if streamingIdentifier == nil {
            streamingIdentifier = identifier
            onEvent?(.messageStarted(messageIdentifier: identifier))
        }
        let target = streamingIdentifier ?? identifier
        onEvent?(.messageDelta(messageIdentifier: target, text: text))

        // CHECK: how the SDK signals the last chunk. Without a reliable end,
        // the typing indicator spins forever and the send button stays as
        // Stop - the exact failure a typed card caused on Sendbird.
        if message.isStreaming != true {
            endStreamIfOpen()
        }
    }

    private func endStreamIfOpen() {
        guard let identifier = streamingIdentifier else {
            return
        }
        streamingIdentifier = nil
        onEvent?(.messageCompleted(messageIdentifier: identifier))
    }
}

enum ThreeDolphinsAdapterError: LocalizedError {
    case attachmentRejected

    var errorDescription: String? {
        "The attachment could not be sent."
    }
}
