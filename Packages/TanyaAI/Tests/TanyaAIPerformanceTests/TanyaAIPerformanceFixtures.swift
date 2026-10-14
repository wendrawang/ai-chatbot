import DesignKit
import Foundation
import TanyaAIDomain

final class TanyaAIRepositoryFixture: TanyaAIRepository {
    var onEvent: ((TanyaAIStreamEvent) -> Void)?
    private(set) var isDisconnected = false

    func connect() {
        onEvent?(.history([]))
        onEvent?(.connectionChanged(.ready))
    }

    func disconnect() { isDisconnected = true }

    func sendMessage(text: String, requestIdentifier: String) -> String? {
        onEvent?(.sendSucceeded(requestIdentifier: requestIdentifier, messageIdentifier: requestIdentifier))
        return requestIdentifier
    }

    func appendMixedMessages() {
        let options = ResponseOptions(
            identifier: "options",
            choices: [
                ResponseChoice(identifier: "first", title: "First option"),
                ResponseChoice(identifier: "second", title: "Second option")
            ])
        let response = ResponsePayload(blocks: [
            .text("A multiline [bold]reply[/bold].\n• First item\n• Second item"),
            .options(options), .note("A reusable native component.")
        ])
        onEvent?(.content(messageIdentifier: "response", content: .response(response)))
        appendMessages(count: 30)
    }

    func appendMessages(count: Int) {
        for index in 0..<count {
            onEvent?(
                .content(
                    messageIdentifier: "performance-\(index)",
                    content: .response(
                        ResponsePayload(
                            blocks: [.text("Message \(index). Native rich text and a wrapped reply."), .note("Detail.")]
                        ))))
        }
        onEvent?(.typing(true))
    }
}
