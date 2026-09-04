public enum TanyaAIStreamEvent: Equatable {
    case responseStarted(messageIdentifier: String)
    case textDelta(messageIdentifier: String, text: String)
    case content(messageIdentifier: String, content: TanyaAIMessageContent)
    case suggestions([TanyaAISuggestionPayload])
    case responseCompleted(messageIdentifier: String)

    /// A hand-off the channel itself asked for, rather than a button on a
    /// card. Only a session transport raises this.
    case hostAction(TanyaAIAction)

    /// The agent or bot is composing. Only a session transport raises this.
    case typing(Bool)
    case heartbeat
}
