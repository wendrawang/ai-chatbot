public struct TanyaAIInformationPayload: Equatable {
    public let title: String?
    public let blocks: [TanyaAIInformationBlock]

    public init(
        title: String?,
        blocks: [TanyaAIInformationBlock]
    ) {
        self.title = title
        self.blocks = blocks
    }
}

public enum TanyaAIInformationBlock: Equatable {
    case text(String)
    case keyValue([TanyaAIKeyValue])
    case bulletList([String])
    case notice(String)
    case divider
}

public struct TanyaAIKeyValue: Equatable {
    public let label: String
    public let value: String

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}
