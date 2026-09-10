import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

/// What a reopened chat shows, and when. The screen stays empty until the
/// channel has said what it held, so nothing is ever drawn to be replaced.
final class TanyaAIChatRestoreTests: XCTestCase {
    /// A reopened conversation is what the customer comes back to, in
    /// place of the greeting they would otherwise be given.
    func testHistoryReplacesTheConversation() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)

        useCase.sendUnsolicited(.history([
            TanyaAIMessage(identifier: "1", role: .user, content: .text("Halo")),
            TanyaAIMessage(identifier: "2", role: .assistant, content: .text("Hai"))
        ]))

        XCTAssertEqual(viewModel.messages.map(\.id), ["1", "2"])
    }

    /// The greeting waits for the channel to say what it held. Showing it
    /// first and swapping it for history is the blink this avoids.
    func testGreetingWaitsUntilHistoryHasBeenReported() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertTrue(viewModel.isRestoring)

        useCase.sendUnsolicited(.history([]))

        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertFalse(viewModel.isRestoring)
    }

    /// Restoring has its own loading state. Typing dots would promise a
    /// reply nobody asked for, and prompts belong to a conversation that has
    /// already said whether it is empty.
    func testRestoringShowsNeitherTypingDotsNorSuggestions() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)

        XCTAssertTrue(viewModel.isRestoring)
        XCTAssertFalse(viewModel.showsTypingRow)
        XCTAssertFalse(viewModel.showsSuggestions)

        useCase.sendUnsolicited(.history([]))

        XCTAssertTrue(viewModel.showsSuggestions)
    }

    /// Typing before the channel answers wins. History is older than what
    /// the customer just sent, so applying it late would delete their
    /// message and the reply being streamed into it.
    func testLateHistoryDoesNotWipeAMessageSentWhileRestoring() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        viewModel.inputText = "Halo"

        viewModel.sendCurrentMessage()
        useCase.sendUnsolicited(.history([
            TanyaAIMessage(identifier: "old", role: .user, content: .text("Lama"))
        ]))

        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(
            viewModel.messages.first?.content,
            TanyaAIMessageContent.text("Halo")
        )
        XCTAssertFalse(viewModel.isRestoring)
    }
}
