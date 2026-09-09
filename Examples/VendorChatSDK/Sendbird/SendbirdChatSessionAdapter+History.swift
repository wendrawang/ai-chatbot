import Foundation
import SendbirdChatSDK
import TanyaAI

/// Reading the conversation back when the chat reopens.
///
/// Split from the adapter proper so the live path - connect, send, receive -
/// stays readable on its own.
extension SendbirdChatSessionAdapter {
    /// How many past messages a reopened conversation shows. No paging: the
    /// customer sees where they left off, not the whole archive.
    static let historyLimit = 50

    /// Reads the conversation back, so reopening the chat is not an empty
    /// screen. Sent before anything else, and only when there is something.
    func loadHistory(
        from channel: GroupChannel,
        completion: @escaping () -> Void
    ) {
        let params = MessageListParams()
        params.previousResultSize = Self.historyLimit
        channel.getMessagesByTimestamp(.max, params: params) { [weak self] messages, _ in
            guard let self, let messages, messages.isEmpty == false else {
                completion()
                return
            }
            let restored = messages
                .sorted { $0.messageId < $1.messageId }
                .compactMap(self.makeHistoryMessage)
            guard restored.isEmpty == false else {
                completion()
                return
            }
            self.onEvent?(.history(restored))
            completion()
        }
    }

    func makeHistoryMessage(
        _ message: BaseMessage
    ) -> TanyaAIChatSessionMessage? {
        let isCustomer = message.sender?.userId
            == SendbirdChat.getCurrentUser()?.userId
        let author: TanyaAIChatSessionMessage.Author =
            isCustomer ? .customer : .assistant
        let identifier = String(message.messageId)
        let text = (message as? UserMessage)?.message ?? ""

        if let name = message.customType,
           name.hasPrefix("content."),
           let json = message.data.data(using: .utf8),
           json.isEmpty == false {
            return TanyaAIChatSessionMessage(
                identifier: identifier,
                author: author,
                text: text,
                structuredName: name,
                structuredJSON: json
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
