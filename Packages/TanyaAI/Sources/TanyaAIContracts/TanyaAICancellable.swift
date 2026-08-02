public protocol TanyaAICancellable: AnyObject {
    func cancel()
}

public final class TanyaAINoOpCancellable: TanyaAICancellable {
    public init() {}

    public func cancel() {}
}
