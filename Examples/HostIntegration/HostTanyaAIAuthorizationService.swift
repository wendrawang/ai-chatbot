import Foundation
import TanyaAI

/// The existing secure authorization API of the host.
///
/// Keep retry, lockout, and error-mapping policy here. The feature only
/// collects the digits and shows the result.
protocol HostTransactionAuthorizing: AnyObject {
    @discardableResult
    func authorizeTransaction(
        transactionIdentifier: String,
        challengeIdentifier: String,
        pin: String,
        completion: @escaping (Result<HostAuthorizationStatus, Error>) -> Void
    ) -> HostCancellableTask
}

enum HostAuthorizationStatus {
    case accepted
    case pending
}

protocol HostCancellableTask: AnyObject {
    func cancel()
}

final class HostTanyaAIAuthorizationService: TanyaAIAuthorizationService {
    private let authorizing: HostTransactionAuthorizing

    init(authorizing: HostTransactionAuthorizing) {
        self.authorizing = authorizing
    }

    @discardableResult
    func authorize(
        request: TanyaAIAuthorizationRequest,
        pin: String,
        completion: @escaping (
            Result<TanyaAIAuthorizationResult, Error>
        ) -> Void
    ) -> TanyaAICancellable {
        guard request.expiresAt > Date() else {
            completion(.failure(HostAuthorizationError.challengeExpired))
            return HostNoOpCancellable()
        }

        // Never log, persist, or copy `pin`. Pass it straight through.
        let task = authorizing.authorizeTransaction(
            transactionIdentifier: request.transactionIdentifier,
            challengeIdentifier: request.challengeIdentifier,
            pin: pin
        ) { result in
            completion(
                result.map { status in
                    TanyaAIAuthorizationResult(
                        transactionIdentifier: request.transactionIdentifier,
                        status: status == .accepted ? .completed : .processing
                    )
                }
            )
        }
        return HostAuthorizationCancellable(task: task)
    }
}

enum HostAuthorizationError: Error {
    case challengeExpired
}

private final class HostNoOpCancellable: TanyaAICancellable {
    func cancel() {}
}

private final class HostAuthorizationCancellable: TanyaAICancellable {
    private let task: HostCancellableTask

    init(task: HostCancellableTask) {
        self.task = task
    }

    func cancel() {
        task.cancel()
    }
}
