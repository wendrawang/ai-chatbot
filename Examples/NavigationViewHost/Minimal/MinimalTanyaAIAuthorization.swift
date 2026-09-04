import Foundation
import TanyaAI

/// The secure authorization API the host already owns.
///
/// Retry, lockout, and error mapping stay here. The feature only collects the
/// digits and shows the outcome.
protocol AppAuthorizationAPI: AnyObject {
    func confirm(
        transactionIdentifier: String,
        challengeIdentifier: String,
        pin: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> AppTask
}

/// Minimal authorization adapter.
///
/// Never log, persist, or copy `pin`. Pass it straight through.
final class MinimalTanyaAIAuthorization: TanyaAIAuthorizationService {
    private let api: AppAuthorizationAPI

    init(api: AppAuthorizationAPI) {
        self.api = api
    }

    @discardableResult
    func authorize(
        request: TanyaAIAuthorizationRequest,
        pin: String,
        completion: @escaping (
            Result<TanyaAIAuthorizationResult, Error>
        ) -> Void
    ) -> TanyaAICancellable {
        let task = api.confirm(
            transactionIdentifier: request.transactionIdentifier,
            challengeIdentifier: request.challengeIdentifier,
            pin: pin
        ) { result in
            completion(
                result.map {
                    TanyaAIAuthorizationResult(
                        transactionIdentifier: request.transactionIdentifier,
                        // Return `.processing` instead when the backend is
                        // still settling the transaction.
                        status: .completed
                    )
                }
            )
        }
        return MinimalCancellable(task.cancel)
    }
}
