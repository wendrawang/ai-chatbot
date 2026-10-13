import Foundation

public struct ResponseDocument: Equatable, Decodable {
    public let identifier: String
    public let title: String
    public let destination: String?
}

public struct ResponseDocuments: Equatable, Decodable {
    public let identifier: String
    public let documents: [ResponseDocument]
    public let continueTitle: String
    public var acceptedIdentifiers: Set<String>
    public var isAuthorized: Bool

    public var isReady: Bool {
        !documents.isEmpty && documents.allSatisfy { acceptedIdentifiers.contains($0.identifier) }
    }

    private enum CodingKeys: String, CodingKey {
        case identifier, documents, continueTitle, acceptedIdentifiers, isAuthorized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        documents = try container.decode([ResponseDocument].self, forKey: .documents)
        continueTitle = try container.decode(String.self, forKey: .continueTitle)
        acceptedIdentifiers = try container.decodeIfPresent(Set<String>.self, forKey: .acceptedIdentifiers) ?? []
        isAuthorized = try container.decodeIfPresent(Bool.self, forKey: .isAuthorized) ?? false
        guard !identifier.isEmpty, !documents.isEmpty, documents.count <= 20,
            documents.allSatisfy({ !$0.identifier.isEmpty }),
            Set(documents.map(\.identifier)).count == documents.count,
            acceptedIdentifiers.isSubset(of: Set(documents.map(\.identifier)))
        else {
            throw CocoaError(.coderReadCorrupt)
        }
    }
}
