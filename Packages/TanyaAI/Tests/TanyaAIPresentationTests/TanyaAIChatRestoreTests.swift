import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

/// What a reopened chat shows, and when. The screen stays empty until the
/// channel has said what it held, so nothing is ever drawn to be replaced.
final class TanyaAIChatRestoreTests: XCTestCase {
    /// A reopened conversation contains only messages from the channel.
    func testHistoryReplacesTheConversation() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)

        useCase.sendUnsolicited(.history([
            TanyaAIMessage(identifier: "1", role: .user, content: .text("Halo")),
            TanyaAIMessage(identifier: "2", role: .assistant, content: .text("Hai"))
        ]))

        XCTAssertEqual(viewModel.messages.map(\.identifier), ["1", "2"])
    }

    /// Empty history finishes loading without inserting a package greeting.
    func testEmptyHistoryDoesNotInsertGreeting() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertTrue(viewModel.isRestoring)

        useCase.sendUnsolicited(.history([]))

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertFalse(viewModel.isRestoring)
    }

    /// Restoring has its own loading state. Typing dots would promise a
    /// reply nobody asked for, and prompts belong to a conversation that has
    /// already said whether it is empty.
    func testRestoringShowsNeitherTypingDotsNorSuggestions() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)

        XCTAssertTrue(viewModel.isRestoring)
        XCTAssertFalse(viewModel.isTypingRowVisible)
        XCTAssertFalse(viewModel.isSuggestionRowVisible)

        useCase.sendUnsolicited(.history([]))

        XCTAssertTrue(viewModel.isSuggestionRowVisible)
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
