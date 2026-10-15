import Foundation

/// An existing host page opened above the chat, with a result returned to the same conversation.
public struct TanyaAIHostFlowRequest: Equatable {
    public enum Kind: Equatable {
        case document
        case authorization
    }

    public let identifier: String
    public let kind: Kind
    public let referenceIdentifier: String
    public let title: String
    public let destination: String?

    public init(
        identifier: String = UUID().uuidString,
        kind: Kind,
        referenceIdentifier: String,
        title: String,
        destination: String? = nil
    ) {
        self.identifier = identifier
        self.kind = kind
        self.referenceIdentifier = referenceIdentifier
        self.title = title
        self.destination = destination
    }
}

/// The host owns document acceptance, authorization and transaction execution. No PIN crosses this contract.
public struct TanyaAIHostFlowResult: Equatable {
    public enum Status: Equatable {
        case accepted
        case processing
        case completed
        case cancelled
    }

    public let status: Status
    public let message: String?

    public init(status: Status, message: String? = nil) {
        self.status = status
        self.message = message
    }
}
