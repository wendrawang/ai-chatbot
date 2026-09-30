import Foundation
import SendbirdChatSDK
import TanyaAI

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

        if let name = message.customType, !name.isEmpty {
            receiveWire(name: name, json: Data(message.data.utf8), identifier: identifier)
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

    private func receiveWire(name: String, json: Data, identifier: String) {
        do {
            onEvent?(try .fromWire(name: name, json: json))
            // A card is a whole message. Streaming ends only on response_completed.
            if TanyaAIEventName.isContentName(name) {
                onEvent?(.messageCompleted(messageIdentifier: identifier))
            }
        } catch {
            onEvent?(.failed(error))
        }
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
