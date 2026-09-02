import Foundation
import TanyaAI

/// Scripted answers for a demo build: no backend, no bot, deterministic.
///
/// Drop it in wherever the real transport goes and the whole feature runs -
/// typed cards, deeplink hand-off, suggestions - before a single endpoint
/// exists:
///
/// ```swift
/// TanyaAIDependencies(
///     streamingTransport: DemoTanyaAITransport(),
///     authorizationService: MockTanyaAIAuthorizationService(),
///     theme: .app
/// )
/// ```
///
/// Debug and test targets only. It answers from a script, so shipping it
/// would mean shipping a chatbot that ignores the backend.
final class DemoTanyaAITransport: TanyaAIStreamingTransport {
    private let queue = DispatchQueue(label: "demo.tanyaai.transport")
    private let chunkDelay: TimeInterval
    private let chunkSize: Int

    /// - Parameters:
    ///   - chunkDelay: pause between chunks, so streaming is visible.
    ///   - chunkSize: bytes per chunk. Deliberately not aligned to event
    ///     boundaries: a script that always arrives in whole events never
    ///     exercises the SSE parser, and the bug then surfaces against the
    ///     real backend instead.
    init(chunkDelay: TimeInterval = 0.03, chunkSize: Int = 24) {
        self.chunkDelay = chunkDelay
        self.chunkSize = chunkSize
    }

    @discardableResult
    func stream(
        _ request: TanyaAIStreamRequest,
        onData: @escaping (Data) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        let prompt = message(from: request.body).lowercased()
        let task = DemoTanyaAITask()
        let chunks = chunked(DemoTanyaAIScript.reply(to: prompt))

        for (index, chunk) in chunks.enumerated() {
            let delay = chunkDelay * Double(index + 1)
            queue.asyncAfter(deadline: .now() + delay) {
                guard task.isCancelled == false else {
                    return
                }
                onData(chunk)
                if index == chunks.count - 1 {
                    completion(.success(()))
                }
            }
        }
        return task
    }

    private func chunked(_ script: String) -> [Data] {
        let data = Data(script.utf8)
        guard data.isEmpty == false else {
            return []
        }
        return stride(from: 0, to: data.count, by: chunkSize).map { start in
            data.subdata(in: start..<min(start + chunkSize, data.count))
        }
    }

    /// The package sends `{"message": "...", "context": {...}}`.
    private func message(from body: Data) -> String {
        let object = try? JSONSerialization.jsonObject(with: body)
        let payload = object as? [String: Any]
        return payload?["message"] as? String ?? ""
    }
}

private final class DemoTanyaAITask: TanyaAICancellable {
    private let lock = NSLock()
    private var cancelled = false

    var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return cancelled
    }

    func cancel() {
        lock.lock()
        cancelled = true
        lock.unlock()
    }
}
