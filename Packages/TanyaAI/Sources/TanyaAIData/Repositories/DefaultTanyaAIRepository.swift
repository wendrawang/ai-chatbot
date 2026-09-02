import Foundation
import TanyaAIContracts
import TanyaAIDomain

public final class DefaultTanyaAIRepository: TanyaAIRepository {
    private let transport: TanyaAIStreamingTransport
    private let messagePath: String
    private let lock = NSLock()
    private var context: TanyaAIContext?

    public init(
        transport: TanyaAIStreamingTransport,
        messagePath: String,
        context: TanyaAIContext? = nil
    ) {
        self.transport = transport
        self.messagePath = messagePath
        self.context = context
    }

    public func updateContext(_ context: TanyaAIContext?) {
        lock.lock()
        self.context = context
        lock.unlock()
    }

    @discardableResult
    public func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        let request = makeRequest(
            conversationIdentifier: conversationIdentifier,
            text: text
        )
        let streamContext = TanyaAIStreamContext()

        return transport.stream(
            request,
            onData: { data in
                streamContext.consume(
                    data,
                    onEvent: onEvent,
                    completion: completion
                )
            },
            completion: { result in
                streamContext.finish(result, completion: completion)
            }
        )
    }

    private func makeRequest(
        conversationIdentifier: String?,
        text: String
    ) -> TanyaAIStreamRequest {
        var payload: [String: Any] = ["message": text]
        if let conversationIdentifier = conversationIdentifier {
            payload["conversationIdentifier"] = conversationIdentifier
        }
        lock.lock()
        let context = self.context
        lock.unlock()
        if let context {
            payload["context"] = context.payload
        }
        let body = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data()
        return TanyaAIStreamRequest(
            path: messagePath,
            body: body,
            requestIdentifier: UUID().uuidString
        )
    }

}
