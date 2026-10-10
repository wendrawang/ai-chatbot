import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

/// What a reopened chat shows, and when. The screen stays empty until the
/// channel has said what it held, so nothing is ever drawn to be replaced.
@MainActor
final class TanyaAIChatRestoreTests: XCTestCase {
    /// A reopened conversation contains only messages from the channel.
    func testHistoryReplacesTheConversation() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)

        repository.sendUnsolicited(.history([
            TanyaAIMessage(identifier: "1", role: .user, content: .text("Halo")),
            TanyaAIMessage(identifier: "2", role: .assistant, content: .text("Hai"))
        ]))

        XCTAssertEqual(viewModel.messages.map(\.identifier), ["1", "2"])
    }

    /// Empty history finishes loading without inserting a package greeting.
    func testEmptyHistoryDoesNotInsertGreeting() {
        let repository = TanyaAIRepositoryStub()
        repository.isAutomaticConnection = false
        let viewModel = TanyaAIChatViewModel(repository: repository)

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertTrue(viewModel.isRestoring)

        repository.sendUnsolicited(.history([]))

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertFalse(viewModel.isRestoring)
    }

    /// Restoring has its own loading state. Typing dots would promise a
    /// reply nobody asked for, and prompts belong to a conversation that has
    /// already said whether it is empty.
    func testRestoringShowsNeitherTypingDotsNorSuggestions() {
        let repository = TanyaAIRepositoryStub()
        repository.isAutomaticConnection = false
        let viewModel = TanyaAIChatViewModel(repository: repository)

        XCTAssertTrue(viewModel.isRestoring)
        XCTAssertFalse(viewModel.isTypingRowVisible)
        XCTAssertFalse(viewModel.isSuggestionRowVisible)

        repository.sendUnsolicited(.history([]))

        XCTAssertFalse(viewModel.isSuggestionRowVisible)
    }

    func testTextReplyDoesNotCreateSuggestions() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        repository.sendUnsolicited(.history([]))
        repository.sendUnsolicited(.responseStarted(messageIdentifier: "reply-1"))
        repository.sendUnsolicited(.textDelta(messageIdentifier: "reply-1", text: "Halo"))
        repository.sendUnsolicited(.responseCompleted(messageIdentifier: "reply-1"))

        XCTAssertTrue(viewModel.suggestions.isEmpty)
        XCTAssertFalse(viewModel.isSuggestionRowVisible)
    }

    /// Typing before the channel answers wins. History is older than what
    /// the customer just sent, so applying it late would delete their
    /// message and the reply being streamed into it.
    func testSendingWaitsForHistoryAndPreservesTheOldConversation() {
        let repository = TanyaAIRepositoryStub()
        repository.isAutomaticConnection = false
        let model = TanyaAIChatViewModel(repository: repository)
        XCTAssertFalse(model.sendMessage("New"))
        repository.send(.history([TanyaAIMessage(identifier: "old", role: .user, content: .text("Old"))]))
        repository.send(.connectionChanged(.ready))
        XCTAssertTrue(model.sendMessage("New"))
        XCTAssertEqual(model.messages.count, 2)
        XCTAssertEqual(model.messages.first?.content, .text("Old"))
    }
}
