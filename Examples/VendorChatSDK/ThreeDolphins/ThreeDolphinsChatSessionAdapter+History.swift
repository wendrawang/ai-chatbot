import Foundation
import TanyaAI
import imi_dolphin_livechat_ios

/// Reading the conversation back when the chat reopens.
///
/// Two round trips rather than one: 3Dolphins lists conversations, then the
/// messages inside one. Both hand back `[[String: Any]]`, so every key below
/// is a guess the docs do not settle.
extension ThreeDolphinsChatSessionAdapter {
    /// How many past messages a reopened conversation shows. No paging: the
    /// customer sees where they left off, not the whole archive.
    static let historyLimit = 100

    func loadHistory(completion: @escaping () -> Void) {
        Connector.shared.fetchConversations(botId: botId) { [weak self] conversations, _ in
            // CHECK: the key naming a conversation. `id` is the guess;
            // `conversationId` and `sessionId` are equally likely.
            guard let self,
                  let latest = conversations.first,
                  let conversationId = latest["id"] as? String else {
                completion()
                return
            }
            self.loadChats(in: conversationId, completion: completion)
        }
    }

    private func loadChats(
        in conversationId: String,
        completion: @escaping () -> Void
    ) {
        Connector.shared.fetchConversationChats(
            conversationId: conversationId,
            botId: botId
        ) { [weak self] chats, _ in
            guard let self else {
                completion()
                return
            }
            let restored = chats
                .suffix(Self.historyLimit)
                .compactMap(self.makeHistoryMessage)
            guard restored.isEmpty == false else {
                completion()
                return
            }
            self.onEvent?(.history(restored))
            completion()
        }
    }

    /// One row of the history response.
    ///
    /// Written against the shape the Chat UI example implies. Every key is
    /// `CHECK:` - the completion hands back untyped dictionaries and the docs
    /// never name a field.
    func makeHistoryMessage(
        _ chat: [String: Any]
    ) -> TanyaAIChatSessionMessage? {
        let identifier = chat["id"] as? String ?? UUID().uuidString
        let text = chat["text"] as? String ?? ""
        // CHECK: how a row says who wrote it. The example app's model uses a
        // `SenderRole` of `.user` or `.ai`; the wire spelling is unpublished.
        let isCustomer = (chat["sender"] as? String)?.lowercased() == "user"
        let author: TanyaAIChatSessionMessage.Author =
            isCustomer ? .customer : .assistant

        if let card = structuredPayload(inHistoryRow: chat) {
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
