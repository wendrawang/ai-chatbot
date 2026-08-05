public enum TanyaAIStreamEvent: Equatable {
    case responseStarted(messageIdentifier: String)
    case textDelta(messageIdentifier: String, text: String)
    case content(messageIdentifier: String, content: TanyaAIMessageContent)
    case suggestions([TanyaAISuggestionPayload])
    case responseCompleted(messageIdentifier: String)
    case heartbeat
}
