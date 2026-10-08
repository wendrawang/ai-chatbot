import XCTest
import TanyaAIDomain

final class ChoicesSelectionTests: XCTestCase {
    func testMultipleSelectionAccumulates() {
        let payload = makePayload(isMultipleSelectionAllowed: true)
            .toggling("dining")
            .toggling("hotel")

        XCTAssertEqual(payload.selected, ["dining", "hotel"])
    }

    func testSingleSelectionReplaces() {
        let payload = makePayload(isMultipleSelectionAllowed: false)
            .toggling("dining")
            .toggling("hotel")

        XCTAssertEqual(payload.selected, ["hotel"])
    }

    func testTappingTheSameChipTwiceClearsIt() {
        let payload = makePayload(isMultipleSelectionAllowed: true)
            .toggling("dining")
            .toggling("dining")

        XCTAssertTrue(payload.selected.isEmpty)
    }

    /// The answer reads in the order the choices were offered, not the order
    /// they happened to be tapped.
    func testAnswerFollowsTheOfferedOrder() {
        let payload = makePayload(isMultipleSelectionAllowed: true)
            .toggling("hotel")
            .toggling("dining")

        XCTAssertEqual(payload.answerPrompt, "Promo dining, Promo hotel")
    }

    func testNothingPickedCannotBeSubmitted() {
        XCTAssertFalse(makePayload().isSubmittable)
        XCTAssertTrue(makePayload().toggling("dining").isSubmittable)
    }

    /// A settled card is a record, not a control.
    func testASubmittedCardCannotBeSubmittedAgain() {
        var payload = makePayload().toggling("dining")
        payload.isSubmitted = true

        XCTAssertFalse(payload.isSubmittable)
    }

    private func makePayload(
        isMultipleSelectionAllowed: Bool = true
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
            isMultipleSelectionAllowed: isMultipleSelectionAllowed
        )
    }
}
