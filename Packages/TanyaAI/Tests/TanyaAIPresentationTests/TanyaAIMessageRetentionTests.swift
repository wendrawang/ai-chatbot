import TanyaAIDomain
import XCTest

@testable import TanyaAIPresentation

@MainActor
final class TanyaAIMessageRetentionTests: XCTestCase {
    func testLiveMessagesKeepOnlyTheNewestHundred() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        for index in 0..<150 {
            repository.sendUnsolicited(
                .content(
                    messageIdentifier: "message-\(index)",
                    content: .text("Reply \(index)")
                ))
        }

        XCTAssertEqual(viewModel.messages.count, 100)
        XCTAssertEqual(viewModel.messages.first?.identifier, "message-50")
        XCTAssertEqual(viewModel.messages.last?.identifier, "message-149")
    }

    func testEvictionReleasesTheRow() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        repository.sendUnsolicited(.content(messageIdentifier: "old", content: .text("Old")))
        weak var evicted: TanyaAIMessageItemViewModel?
        evicted = viewModel.messages.first

        for index in 0..<100 {
            repository.sendUnsolicited(
                .content(
                    messageIdentifier: "new-\(index)", content: .text("New")
                ))
        }

        XCTAssertNil(evicted)
    }

    func testRestorationAlsoBoundsInjectedUseCases() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        let history = (0..<150).map { index in
            TanyaAIMessage(identifier: "\(index)", role: .assistant, content: .text("History"))
        }

        repository.sendUnsolicited(.history(history))

        XCTAssertEqual(viewModel.messages.count, 100)
        XCTAssertEqual(viewModel.messages.first?.identifier, "50")
    }
}
