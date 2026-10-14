import TanyaAIDomain
import XCTest

@testable import TanyaAIPresentation

@MainActor
final class TanyaAIRowRefreshTests: XCTestCase {
    func testReplacingAMessageObjectWithTheSameIdentifierRefreshesTheRow() {
        let original = state(text: "Old")
        let updated = state(text: "New")
        XCTAssertTrue(updated.rowsDiffer(from: original))
        XCTAssertNil(updated.kind(at: -1))
    }

    private func state(text: String) -> TanyaAIMessageListState {
        let message = TanyaAIMessageItemViewModel(
            message: TanyaAIMessage(
                identifier: "same-message", role: .assistant, content: .text(text)
            ))
        return TanyaAIMessageListState(messages: [message], isRestoring: false, isTypingRowVisible: false)
    }
}
