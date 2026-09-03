import Foundation
import TanyaAI

/// The streaming API the host networking layer already exposes.
///
/// Most banking stacks have one: a POST that reports response chunks as they
/// arrive. mTLS, pinning, headers, token refresh, timeout, tracing, and
/// logging already live inside it.
///
/// If yours cannot stream, use `Production/HostTanyaAIStreamingTransport`
/// instead. Do not fall back to `dataTask(with:completionHandler:)`: it
/// buffers the whole response, so every bubble appears at once at the end.
protocol AppStreamingClient: AnyObject {
    func streamPOST(
        path: String,
        body: Data,
        onChunk: @escaping (Data) -> Void,
        onFinish: @escaping (Result<Void, Error>) -> Void
    ) -> AppTask
}

protocol AppTask: AnyObject {
    func cancel()
}

/// Minimal transport: forward the request, forward the raw chunks back.
///
/// The package parses the SSE framing itself, so never buffer, decode, or
/// reshape the chunks here.
final class MinimalTanyaAITransport: TanyaAIStreamingTransport {
    private let client: AppStreamingClient

    init(client: AppStreamingClient) {
        self.client = client
    }

    @discardableResult
    func stream(
        _ request: TanyaAIStreamRequest,
        onData: @escaping (Data) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        let task = client.streamPOST(
            path: request.path,
            body: request.body,
            onChunk: onData,
            onFinish: completion
        )
        return MinimalCancellable(task.cancel)
    }
}

final class MinimalCancellable: TanyaAICancellable {
    private let action: () -> Void

    init(_ action: @escaping () -> Void) {
        self.action = action
    }

    func cancel() {
        action()
    }
}
