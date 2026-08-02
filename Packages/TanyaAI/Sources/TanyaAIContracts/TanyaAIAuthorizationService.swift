import Foundation

public struct TanyaAIAuthorizationRequest: Equatable {
    public let approvalIdentifier: String
    public let transactionIdentifier: String
    public let challengeIdentifier: String
    public let expiresAt: Date

    public init(
        approvalIdentifier: String,
        transactionIdentifier: String,
        challengeIdentifier: String,
        expiresAt: Date
    ) {
        self.approvalIdentifier = approvalIdentifier
        self.transactionIdentifier = transactionIdentifier
        self.challengeIdentifier = challengeIdentifier
        self.expiresAt = expiresAt
    }
}

public struct TanyaAIAuthorizationResult: Equatable {
    public enum Status: Equatable {
        case processing
        case completed
    }

    public let transactionIdentifier: String
    public let status: Status

    public init(
        transactionIdentifier: String,
        status: Status
    ) {
        self.transactionIdentifier = transactionIdentifier
        self.status = status
    }
}

public protocol TanyaAIAuthorizationService: AnyObject {
    @discardableResult
    func authorize(
        request: TanyaAIAuthorizationRequest,
        pin: String,
        completion: @escaping (
            Result<TanyaAIAuthorizationResult, Error>
        ) -> Void
    ) -> TanyaAICancellable
}
