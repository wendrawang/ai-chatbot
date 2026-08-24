import Foundation

public struct TanyaAIApprovalPayload: Equatable {
    public enum Kind: String, Equatable {
        case currencyConversion
        case timeDeposit
        case transfer
        case savingsPlan
        case generic
    }

    public enum State: String, Equatable {
        case awaitingApproval
        case authorizing
        case processing
        case completed
        case failed
        case expired
        case cancelled
    }

    public let approvalIdentifier: String
    public let transactionIdentifier: String
    public let challengeIdentifier: String
    public let kind: Kind
    public let title: String
    public let summary: [TanyaAIKeyValue]
    public let notice: String?
    public let expiresAt: Date
    /// When present, Confirm hands the deeplink to the host instead of
    /// opening the in-feature PIN sheet. Use it while an existing screen still
    /// owns the transaction.
    public let handoff: TanyaAIAction?
    public var state: State

    public init(
        approvalIdentifier: String,
        transactionIdentifier: String,
        challengeIdentifier: String,
        kind: Kind = .generic,
        title: String,
        summary: [TanyaAIKeyValue],
        notice: String? = nil,
        expiresAt: Date,
        handoff: TanyaAIAction? = nil,
        state: State
    ) {
        self.approvalIdentifier = approvalIdentifier
        self.transactionIdentifier = transactionIdentifier
        self.challengeIdentifier = challengeIdentifier
        self.kind = kind
        self.title = title
        self.summary = summary
        self.notice = notice
        self.expiresAt = expiresAt
        self.handoff = handoff
        self.state = state
    }
}
