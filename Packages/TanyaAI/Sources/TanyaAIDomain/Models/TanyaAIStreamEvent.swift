import DesignKit

public enum TanyaAIStreamEvent: Equatable {
    case connectionChanged(TanyaAIConnectionState)
    case historyFailed
    case sendSucceeded(requestIdentifier: String, messageIdentifier: String?)
    case sendFailed(requestIdentifier: String)
    case responseStarted(messageIdentifier: String)
    case textDelta(messageIdentifier: String, text: String)
    case content(messageIdentifier: String, content: TanyaAIMessageContent)
    /// Prompts offered with the question they answer. The title is the
    /// question - "Kategori apa yang diinginkan" - and is optional, because
    /// a reply may offer follow-ups that need no heading.
    case suggestions(title: String?, items: [TanyaAISuggestionPayload])
    case responseCompleted(messageIdentifier: String)

    /// A hand-off the channel itself asked for, rather than a button on a
    /// card. Only a session transport raises this.
    case hostAction(Action)

    /// The agent or bot is composing. Only a session transport raises this.
    case typing(Bool)
    /// A snapshot in SDK order; local outbox rows survive a reload.
    case history([TanyaAIMessage])

    case heartbeat
}
