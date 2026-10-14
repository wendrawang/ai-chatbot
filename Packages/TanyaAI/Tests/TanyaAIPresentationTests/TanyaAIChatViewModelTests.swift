import DesignKit
import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest

@testable import TanyaAIPresentation

@MainActor
final class TanyaAIChatViewModelTests: XCTestCase {
    func testSendingMessageAddsUserAndStreamedAssistantMessages() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        viewModel.sendMessage("Hello")
        repository.send(.responseStarted(messageIdentifier: "assistant-1"))
        repository.send(
            .textDelta(messageIdentifier: "assistant-1", text: "Hi there")
        )
        repository.complete(.success(()))

        XCTAssertEqual(viewModel.messages.count, 2)
        XCTAssertEqual(viewModel.messages[0].content, .text("Hello"))
        XCTAssertEqual(viewModel.messages[1].content, .text("Hi there"))
        XCTAssertFalse(viewModel.isAgentTyping)
    }

    /// A bot that greets first, or any reply arriving between turns, still
    /// belongs on screen. The session reports these outside a turn, and
    /// nothing consumed them before.
    func testUnpromptedReplyIsRendered() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        let before = viewModel.messages.count

        repository.sendUnsolicited(.responseStarted(messageIdentifier: "greet"))
        repository.sendUnsolicited(
            .textDelta(messageIdentifier: "greet", text: "Halo!")
        )
        repository.sendUnsolicited(.responseCompleted(messageIdentifier: "greet"))

        XCTAssertEqual(viewModel.messages.count, before + 1)
        XCTAssertFalse(viewModel.isAgentTyping)
    }

}
