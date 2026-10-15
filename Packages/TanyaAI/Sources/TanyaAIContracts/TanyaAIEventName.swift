/// The current wire vocabulary. Display content uses one ordered response.
public enum TanyaAIEventName: String, CaseIterable {
    case response
    case responseStarted = "response_started"
    case textDelta = "text_delta"
    case responseCompleted = "response_completed"
    case heartbeat

    public init?(wireName: String) {
        switch wireName {
        case "response.started": self = .responseStarted
        case "text.delta": self = .textDelta
        case "response.completed": self = .responseCompleted
        case "content.response": self = .response
        default: self.init(rawValue: wireName)
        }
    }

    public var isContent: Bool { self == .response }

    public static func isContentName(_ name: String) -> Bool {
        if let event = Self(wireName: name) { return event.isContent }
        return name.hasPrefix("content.") || (!name.isEmpty && !name.contains("."))
    }
}
