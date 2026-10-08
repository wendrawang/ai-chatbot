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

}
