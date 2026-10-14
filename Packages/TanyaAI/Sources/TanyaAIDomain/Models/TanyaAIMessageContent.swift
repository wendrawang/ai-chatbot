public enum TanyaAIMessageContent: Equatable {
    case text(String)
    case response(ResponsePayload)
    case unsupported(String?)
}
