import XCTest
@testable import DesignKit

final class ChartGeometryTests: XCTestCase {
    func testFractionsDoNotOverflowAndIgnoreInvalidValues() {
        let fractions = ChartGeometry.fractions([.greatestFiniteMagnitude, .greatestFiniteMagnitude, .nan, -1])
        XCTAssertEqual(fractions, [0.5, 0.5, 0, 0])
        XCTAssertEqual(ChartGeometry.fractions([0, 0]), [0, 0])
    }

    func testLineSupportsNegativeAndConstantValues() {
        let heights = ChartGeometry.lineHeights([-.greatestFiniteMagnitude, 0, .greatestFiniteMagnitude])
        XCTAssertEqual(heights, [0, 0.5, 1])
        XCTAssertEqual(ChartGeometry.lineHeights([42]), [0.5])
        XCTAssertEqual(ChartGeometry.lineHeights([]), [])
    }
}
