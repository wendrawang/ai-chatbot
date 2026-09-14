import Foundation
import TanyaAIContracts
import TanyaAIDomain

/// Turning what the channel already held into what the screen shows.
///
/// Split from the repository proper so the live path - a turn opening,
/// streaming and closing - stays readable on its own.
extension TanyaAISessionRepository {
    func reportEmptyHistoryIfNeeded() {
        lock.lock()
        let needed = !hasReportedHistory
        hasReportedHistory = true
        lock.unlock()
        guard needed else {
            return
        }
        emit(.history([]))
    }

    /// A past message becomes the same content a live one would, so history
    /// and new replies render through one path.
    ///
    /// A card that no longer decodes degrades to the unsupported bubble
    /// rather than dropping the message out of the conversation.
    func makeHistoryMessage(
        _ message: TanyaAIChatSessionMessage
    ) -> TanyaAIMessage {
        TanyaAIMessage(
            identifier: message.identifier,
            role: message.author == .customer ? .user : .assistant,
            content: historyContent(message)
        )
    }

    func historyContent(
        _ message: TanyaAIChatSessionMessage
    ) -> TanyaAIMessageContent {
        guard let name = message.structuredName,
              let json = message.structuredJSON else {
            return .text(message.text)
        }
        guard let event = try? decoder.decode(name: name, json: json),
              case .content(_, let content) = event else {
            return .unsupported("This content requires a newer app version.")
        }
        return content
    }

    /// A malformed card must not tear down the channel: it degrades to the
    /// unsupported fallback.
}
