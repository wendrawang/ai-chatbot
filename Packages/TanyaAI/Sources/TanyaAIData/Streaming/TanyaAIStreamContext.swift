import Foundation
import TanyaAIDomain

final class TanyaAIStreamContext {
    private let parser = TanyaAISSEParser()
    private let decoder = TanyaAIStreamEventDecoder()
    private let processingQueue = DispatchQueue(
        label: "com.example.tanyaai.stream-processing"
    )
    private var completed = false

    func consume(
        _ data: Data,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        processingQueue.async {
            guard !self.completed else {
                return
            }
            do {
                for event in self.parser.append(data) {
                    if let streamEvent = try self.decoder.decode(event) {
                        onEvent(streamEvent)
                    }
                }
            } catch {
                self.complete(.failure(error), completion: completion)
            }
        }
    }

    func finish(
        _ result: Result<Void, Error>,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        processingQueue.async {
            self.complete(result, completion: completion)
        }
    }

    private func complete(
        _ result: Result<Void, Error>,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard !completed else {
            return
        }
        completed = true
        parser.reset()
        completion(result)
    }
}
