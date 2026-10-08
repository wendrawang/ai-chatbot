import DesignKit

/// One bot answer composed from any subset of the four approved content parts.
public struct AnswerPayload: Equatable {
    public let text: String?
    public let options: [Suggestion]
    public let image: ImagePayload?
    public let actions: ActionPayload?
    /// Restored answered options stay hidden. Other content remains readable.
    public var isAnswered: Bool

    public init(
        text: String? = nil,
        options: [Suggestion] = [],
        image: ImagePayload? = nil,
        actions: ActionPayload? = nil,
        isAnswered: Bool = false
    ) {
        self.text = text
        self.options = options
        self.image = image
        self.actions = actions
        self.isAnswered = isAnswered
    }
}
