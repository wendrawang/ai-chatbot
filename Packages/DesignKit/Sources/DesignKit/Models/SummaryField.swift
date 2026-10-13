public struct SummaryField: Codable, Equatable {
    public let label: String
    public let value: String
    public let isEmphasized: Bool

    public init(label: String, value: String, isEmphasized: Bool = false) {
        self.label = label
        self.value = value
        self.isEmphasized = isEmphasized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            label: try container.decode(String.self, forKey: .label),
            value: try container.decode(String.self, forKey: .value),
            isEmphasized: try container.decodeIfPresent(Bool.self, forKey: .isEmphasized) ?? false
        )
    }
}
