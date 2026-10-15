import Foundation

public struct ResponseChoice: Equatable, Decodable {
    public let identifier: String
    public let title: String
    public let prompt: String

    public init(identifier: String, title: String, prompt: String? = nil) {
        self.identifier = identifier
        self.title = title
        self.prompt = prompt ?? title
    }

    private enum CodingKeys: String, CodingKey { case identifier, title, prompt }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            identifier: try container.decode(String.self, forKey: .identifier),
            title: try container.decode(String.self, forKey: .title),
            prompt: try container.decodeIfPresent(String.self, forKey: .prompt)
        )
    }
}

public struct ResponseOptions: Equatable, Decodable {
    public let identifier: String
    public let title: String?
    public let choices: [ResponseChoice]
    public var selectedIdentifier: String?
    public var isReadOnly: Bool

    public init(
        identifier: String, title: String? = nil, choices: [ResponseChoice],
        selectedIdentifier: String? = nil, isReadOnly: Bool = false
    ) {
        self.identifier = identifier
        self.title = title
        self.choices = choices
        self.selectedIdentifier = selectedIdentifier
        self.isReadOnly = isReadOnly
    }

    private enum CodingKeys: String, CodingKey {
        case identifier, title, choices, selectedIdentifier, isReadOnly
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let choices = try container.decode([ResponseChoice].self, forKey: .choices)
        guard !choices.isEmpty, choices.count <= 100,
            choices.allSatisfy({ !$0.identifier.isEmpty && !$0.prompt.isEmpty }),
            Set(choices.map(\.identifier)).count == choices.count
        else { throw CocoaError(.coderReadCorrupt) }
        self.init(
            identifier: try container.decode(String.self, forKey: .identifier),
            title: try container.decodeIfPresent(String.self, forKey: .title),
            choices: choices,
            selectedIdentifier: try container.decodeIfPresent(String.self, forKey: .selectedIdentifier),
            isReadOnly: try container.decodeIfPresent(Bool.self, forKey: .isReadOnly) ?? false
        )
        if let selectedIdentifier, !choices.contains(where: { $0.identifier == selectedIdentifier }) {
            throw CocoaError(.coderReadCorrupt)
        }
    }
}
