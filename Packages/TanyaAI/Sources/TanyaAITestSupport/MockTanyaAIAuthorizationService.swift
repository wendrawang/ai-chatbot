import Foundation
import TanyaAIContracts

public enum MockTanyaAIAuthorizationError: Error, Equatable {
    case invalidPIN
    case expired
}

public final class MockTanyaAIAuthorizationService:
    TanyaAIAuthorizationService {

    private let acceptedPIN: String
    private let callbackQueue: DispatchQueue
    private let delay: TimeInterval

    public init(
        acceptedPIN: String = "123456",
        callbackQueue: DispatchQueue = .main,
        delay: TimeInterval = 0.35
    ) {
        self.acceptedPIN = acceptedPIN
        self.callbackQueue = callbackQueue
        self.delay = delay
    }

    @discardableResult
    public func authorize(
        request: TanyaAIAuthorizationRequest,
        pin: String,
        completion: @escaping (
            Result<TanyaAIAuthorizationResult, Error>
        ) -> Void
    ) -> TanyaAICancellable {
        let task = MockTanyaAITask()
        let workItem = DispatchWorkItem {
            guard task.isCancelled == false else {
                return
            }
            completion(self.result(for: request, pin: pin))
            task.finish()
        }
        task.add(workItem)
        callbackQueue.asyncAfter(
            deadline: .now() + delay,
            execute: workItem
        )
        return task
    }

    private func result(
        for request: TanyaAIAuthorizationRequest,
        pin: String
    ) -> Result<TanyaAIAuthorizationResult, Error> {
        guard request.expiresAt > Date() else {
            return .failure(MockTanyaAIAuthorizationError.expired)
        }
        guard pin == acceptedPIN else {
            return .failure(MockTanyaAIAuthorizationError.invalidPIN)
        }
        return .success(
            TanyaAIAuthorizationResult(
                transactionIdentifier: request.transactionIdentifier,
                status: .completed
            )
        )
    }
}
