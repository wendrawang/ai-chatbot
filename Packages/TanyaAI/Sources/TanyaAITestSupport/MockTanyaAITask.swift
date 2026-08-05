import Foundation
import TanyaAIContracts

public final class MockTanyaAITask: TanyaAICancellable {
    private let lock = NSLock()
    private var workItems: [DispatchWorkItem] = []
    private var cancelled = false

    public init() {}

    public func add(_ workItem: DispatchWorkItem) {
        lock.lock()
        workItems.append(workItem)
        let shouldCancel = cancelled
        lock.unlock()

        if shouldCancel {
            workItem.cancel()
        }
    }

    public func cancel() {
        lock.lock()
        cancelled = true
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
        return cancelled
    }
}
