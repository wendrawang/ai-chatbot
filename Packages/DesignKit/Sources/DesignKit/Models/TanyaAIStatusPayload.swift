public struct TanyaAIStatusPayload: Equatable {
    public enum Level: String, Equatable {
        case neutral
        case success
        case warning
        case error
    }

    public let title: String
    public let detail: String
    public let level: Level

    public init(
        title: String,
        detail: String,
        level: Level
    ) {
        self.title = title
        self.detail = detail
        self.level = level
    }
}
