import Foundation

public struct TanyaAIStreamRequest: Equatable {
    public let path: String
    public let body: Data
    public let requestIdentifier: String

    public init(
        path: String,
        body: Data,
        requestIdentifier: String
    ) {
        self.path = path
        self.body = body
        self.requestIdentifier = requestIdentifier
    }
}

public protocol TanyaAIStreamingTransport: AnyObject {
    @discardableResult
    func stream(
        _ request: TanyaAIStreamRequest,
        onData: @escaping (Data) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable
}
