/// One channel, with one event stream delivered on the main queue.
public protocol TanyaAIRepository: AnyObject {
    var onEvent: ((TanyaAIStreamEvent) -> Void)? { get set }
    func connect()
    @discardableResult
    func sendMessage(text: String, requestIdentifier: String) -> String?
    func disconnect()
}
