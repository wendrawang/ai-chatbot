import Foundation

public struct TanyaAIApprovalPayload: Equatable {
    public enum State: String, Equatable {
        case awaitingApproval
        case authorizing
        case processing
        case completed
        case failed
        case expired
    }

    public let approvalIdentifier: String
    public let transactionIdentifier: String
    public let challengeIdentifier: String
    public let title: String
    public let summary: [TanyaAIKeyValue]
    public let expiresAt: Date
    public var state: State

    public init(
        approvalIdentifier: String,
        transactionIdentifier: String,
        challengeIdentifier: String,
        title: String,
        summary: [TanyaAIKeyValue],
        expiresAt: Date,
        state: State
    ) {
        self.approvalIdentifier = approvalIdentifier
        self.transactionIdentifier = transactionIdentifier
        self.challengeIdentifier = challengeIdentifier
        self.title = title
        self.summary = summary
        self.expiresAt = expiresAt
        self.state = state
    }
}
