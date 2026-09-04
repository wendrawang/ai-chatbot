import Foundation
import TanyaAIContracts
import TanyaAIDomain

public enum TanyaAITransportError: Error {
    /// No transport was injected. Both `TanyaAIDependencies` initializers
    /// require one, so this is unreachable through the public API and exists
    /// only so a future mistake surfaces as an error banner rather than a
    /// crash in a banking app.
    case transportMissing
}

public final class TanyaAIUnavailableRepository: TanyaAIRepository {
    public init() {}

    @discardableResult
    public func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        completion(.failure(TanyaAITransportError.transportMissing))
        return TanyaAINoOpCancellable()
    }
}
