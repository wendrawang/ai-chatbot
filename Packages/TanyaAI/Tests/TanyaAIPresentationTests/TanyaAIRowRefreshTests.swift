import DesignKit
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIRowRefreshTests: XCTestCase {
    func testSameSuggestionIdentifierWithNewContentRefreshesTheRow() {
        let original = makeState(title: "Old", prompt: "Old prompt")
        let updated = makeState(title: "New", prompt: "New prompt")

        XCTAssertTrue(updated.rowsDiffer(from: original))
    }

    func testOnlyTheSuggestionHeadingChangingRefreshesTheRow() {
        let original = makeState(title: "Choice", heading: "Old question")
        let updated = makeState(title: "Choice", heading: "New question")

        XCTAssertTrue(updated.rowsDiffer(from: original))
    }

    func testReplacingAMessageObjectWithTheSameIdentifierRefreshesTheRow() {
        let original = makeState(title: "Choice", messageText: "Old")
        let updated = makeState(title: "Choice", messageText: "New")

        XCTAssertTrue(updated.rowsDiffer(from: original))
        XCTAssertNil(updated.kind(at: -1))
    }

    private func makeState(
        title: String,
        prompt: String = "Prompt",
        heading: String? = nil,
        messageText: String? = nil
    ) -> TanyaAIMessageListState {
        let messages = messageText.map { text in
            [TanyaAIMessageItemViewModel(message: TanyaAIMessage(
                identifier: "same-message", role: .assistant, content: .text(text)
            ))]
        } ?? []
        return TanyaAIMessageListState(
            messages: messages,
            isRestoring: false,
            isTypingRowVisible: false,
            suggestions: [Suggestion(identifier: "same", title: title, prompt: prompt)],
            suggestionsTitle: heading
        )
    }
}
