import DesignKit
import Foundation

/// Ordered display blocks; layout and user intent stay independent of the transport.
public struct ResponsePayload: Equatable, Decodable {
    public var blocks: [ResponseBlock]
    public var isReadOnly: Bool

    public init(blocks: [ResponseBlock], isReadOnly: Bool = false) {
        self.blocks = blocks
        self.isReadOnly = isReadOnly
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let blocks = try container.decode([ResponseBlock].self, forKey: .blocks)
        guard !blocks.isEmpty, blocks.count <= 64 else { throw CocoaError(.coderReadCorrupt) }
        self.blocks = blocks
        isReadOnly = try container.decodeIfPresent(Bool.self, forKey: .isReadOnly) ?? false
    }

    private enum CodingKeys: String, CodingKey { case blocks, isReadOnly }
}

public enum ResponseBlock: Equatable, Decodable {
    case text(String)
    case note(String)
    case table(DataTableData)
    case actions([ResponseAction])
    case options(ResponseOptions)
    case metric(ResponseMetric)
    case summary(ResponseSummary)
    case documents(ResponseDocuments)
    case activity(String)

    private enum CodingKeys: String, CodingKey {
        case type, text, table, actions, options, metric, summary, documents
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .type) {
        case "text": self = .text(try container.decode(String.self, forKey: .text))
        case "note": self = .note(try container.decode(String.self, forKey: .text))
        case "table": self = .table(try container.decode(DataTableData.self, forKey: .table))
        case "actions": self = .actions(try container.decode([ResponseAction].self, forKey: .actions))
        case "options": self = .options(try container.decode(ResponseOptions.self, forKey: .options))
        case "metric": self = .metric(try container.decode(ResponseMetric.self, forKey: .metric))
        case "summary": self = .summary(try container.decode(ResponseSummary.self, forKey: .summary))
        case "documents": self = .documents(try container.decode(ResponseDocuments.self, forKey: .documents))
        case "activity": self = .activity(try container.decode(String.self, forKey: .text))
        default: throw CocoaError(.coderReadCorrupt)
        }
    }
}
