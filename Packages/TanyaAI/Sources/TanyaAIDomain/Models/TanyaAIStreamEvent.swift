public enum TanyaAIStreamEvent: Equatable {
    case responseStarted(messageIdentifier: String)
    case textDelta(messageIdentifier: String, text: String)
    case content(messageIdentifier: String, content: TanyaAIMessageContent)
    case suggestions([TanyaAISuggestionPayload])
    case responseCompleted(messageIdentifier: String)
    /// The channel asked the host to open something. Reported straight to the
    /// host, never rendered.
    case hostAction(TanyaAIAction)
    /// The agent or bot is composing. Only a session transport produces this.
    case typing(Bool)
    case heartbeat
}
