import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIMessageRetentionTests: XCTestCase {
    func testLiveMessagesKeepOnlyTheNewestHundred() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        for index in 0..<150 {
            useCase.sendUnsolicited(.content(
                messageIdentifier: "message-\(index)",
                content: .text("Reply \(index)")
            ))
        }

        XCTAssertEqual(viewModel.messages.count, 100)
        XCTAssertEqual(viewModel.messages.first?.identifier, "message-50")
        XCTAssertEqual(viewModel.messages.last?.identifier, "message-149")
    }

    func testEvictionReleasesTheRowAndItsRedirect() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        useCase.sendUnsolicited(.content(messageIdentifier: "old", content: .text("Old")))
        weak var evicted: TanyaAIMessageItemViewModel?
        evicted = viewModel.messages.first
        viewModel.redirectedIdentifiers["original"] = "old"

        for index in 0..<100 {
            useCase.sendUnsolicited(.content(
                messageIdentifier: "new-\(index)", content: .text("New")
            ))
        }

        XCTAssertNil(evicted)
        XCTAssertTrue(viewModel.redirectedIdentifiers.isEmpty)
    }

    func testRestorationAlsoBoundsInjectedUseCases() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        let history = (0..<150).map { index in
            TanyaAIMessage(identifier: "\(index)", role: .assistant, content: .text("History"))
        }

        useCase.sendUnsolicited(.history(history))

        XCTAssertEqual(viewModel.messages.count, 100)
        XCTAssertEqual(viewModel.messages.first?.identifier, "50")
    }
}
