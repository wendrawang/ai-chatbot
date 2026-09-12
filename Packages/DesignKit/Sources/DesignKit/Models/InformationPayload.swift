public struct InformationPayload: Equatable {
    public let title: String?
    public let blocks: [InformationBlock]

    public init(
        title: String?,
        blocks: [InformationBlock]
    ) {
        self.title = title
        self.blocks = blocks
    }
}

public enum InformationBlock: Equatable {
    case text(String)
    case keyValue([KeyValue])
    case bulletList([String])
    case notice(String)
    case divider
}

public struct KeyValue: Equatable {
    public let label: String
    public let value: String

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}
