import Foundation
import TanyaAIContracts

public final class MockTanyaAIStreamingTransport: TanyaAIStreamingTransport {
    public enum Scenario {
        case adaptiveDemo
        case custom([Data])
        case failure(Error)
    }

    private let scenario: Scenario
    private let callbackQueue: DispatchQueue
    private let chunkDelay: TimeInterval

    public init(
        scenario: Scenario = .adaptiveDemo,
        callbackQueue: DispatchQueue = .main,
        chunkDelay: TimeInterval = 0.04
    ) {
        self.scenario = scenario
        self.callbackQueue = callbackQueue
        self.chunkDelay = chunkDelay
    }

    @discardableResult
    public func stream(
        _ request: TanyaAIStreamRequest,
        onData: @escaping (Data) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        let task = MockTanyaAITask()

        switch scenario {
        case .adaptiveDemo:
            schedule(
                chunks: MockTanyaAIResponseFixture.chunks(for: request),
                task: task,
                onData: onData,
                completion: completion
            )
        case .custom(let chunks):
            schedule(
                chunks: chunks,
                task: task,
                onData: onData,
                completion: completion
            )
        case .failure(let error):
            scheduleFailure(error, task: task, completion: completion)
        }
        return task
    }

    private func schedule(
        chunks: [Data],
        task: MockTanyaAITask,
        onData: @escaping (Data) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        for (index, data) in chunks.enumerated() {
            let workItem = DispatchWorkItem {
                guard task.isCancelled == false else {
                    return
                }
                onData(data)
                if index == chunks.count - 1 {
                    completion(.success(()))
                    task.finish()
                }
            }
            task.add(workItem)
            let delay = chunkDelay * Double(index + 1)
            callbackQueue.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }

    private func scheduleFailure(
        _ error: Error,
        task: MockTanyaAITask,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let workItem = DispatchWorkItem {
            guard task.isCancelled == false else {
                return
            }
            completion(.failure(error))
            task.finish()
        }
        task.add(workItem)
        callbackQueue.asyncAfter(
            deadline: .now() + chunkDelay,
            execute: workItem
        )
    }
}
