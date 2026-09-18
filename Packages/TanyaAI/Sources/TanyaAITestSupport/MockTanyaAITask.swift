import Foundation
import TanyaAIContracts

public final class MockTanyaAITask: TanyaAICancellable {
    private let lock = NSLock()
    private var workItems: [DispatchWorkItem] = []
    private var isTaskCancelled = false

    public init() {}

    public func add(_ workItem: DispatchWorkItem) {
        lock.lock()
        workItems.append(workItem)
        let isCancellationNeeded = isTaskCancelled
        lock.unlock()

        if isCancellationNeeded {
            workItem.cancel()
        }
    }

    public func cancel() {
        lock.lock()
        isTaskCancelled = true
        let pendingItems = workItems
        workItems.removeAll()
        lock.unlock()
        pendingItems.forEach { $0.cancel() }
    }

    public func finish() {
        lock.lock()
        workItems.removeAll()
        lock.unlock()
    }

    public var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return isTaskCancelled
    }
}
