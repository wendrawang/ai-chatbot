import XCTest
@testable import DesignKit

/// The question answered by picking and confirming.
final class ChoicesTests: XCTestCase {
    func testChipsFillARowBeforeStartingTheNext() {
        let rows = ChipLayout.rows(
            widths: [100, 100, 100],
            maxWidth: 220,
            spacing: 10
        )

        XCTAssertEqual(rows, [[0, 1], [2]])
    }

    /// Losing a choice would be worse than a chip that reaches both edges, so
    /// one too wide to fit takes a row of its own rather than disappearing.
    func testAChipWiderThanTheRowKeepsItsOwnRow() {
        let rows = ChipLayout.rows(
            widths: [400, 50],
            maxWidth: 220,
            spacing: 10
        )

        XCTAssertEqual(rows, [[0], [1]])
    }

    func testSpacingCountsAgainstTheRow() {
        // 100 + 100 fits exactly; the spacing between them is what does not.
        let rows = ChipLayout.rows(
            widths: [100, 100],
            maxWidth: 200,
            spacing: 10
        )

        XCTAssertEqual(rows, [[0], [1]])
    }

    func testMultipleSelectionAccumulates() {
        let payload = makePayload(allowsMultipleSelection: true)
            .toggling("dining")
            .toggling("hotel")

        XCTAssertEqual(payload.selected, ["dining", "hotel"])
    }

    func testSingleSelectionReplaces() {
        let payload = makePayload(allowsMultipleSelection: false)
            .toggling("dining")
            .toggling("hotel")

        XCTAssertEqual(payload.selected, ["hotel"])
    }

    func testTappingTheSameChipTwiceClearsIt() {
        let payload = makePayload(allowsMultipleSelection: true)
            .toggling("dining")
            .toggling("dining")

        XCTAssertTrue(payload.selected.isEmpty)
    }

    /// The answer reads in the order the choices were offered, not the order
    /// they happened to be tapped.
    func testAnswerFollowsTheOfferedOrder() {
        let payload = makePayload(allowsMultipleSelection: true)
            .toggling("hotel")
            .toggling("dining")

        XCTAssertEqual(payload.answerPrompt, "Promo dining, Promo hotel")
    }

    func testNothingPickedCannotBeSubmitted() {
        XCTAssertFalse(makePayload().canSubmit)
        XCTAssertTrue(makePayload().toggling("dining").canSubmit)
    }

    /// A settled card is a record, not a control.
    func testASubmittedCardCannotBeSubmittedAgain() {
        var payload = makePayload().toggling("dining")
        payload.isSubmitted = true

        XCTAssertFalse(payload.canSubmit)
    }

    private func makePayload(
        allowsMultipleSelection: Bool = true
    ) -> ChoicesPayload {
        ChoicesPayload(
            identifier: "q1",
            title: "Kategori apa yang diinginkan",
            choices: [
                .init(
                    identifier: "dining",
                    title: "Dining",
                    prompt: "Promo dining"
                ),
                .init(
                    identifier: "hotel",
                    title: "Hotel & Travel",
                    prompt: "Promo hotel"
                )
            ],
            allowsMultipleSelection: allowsMultipleSelection
        )
    }
}
