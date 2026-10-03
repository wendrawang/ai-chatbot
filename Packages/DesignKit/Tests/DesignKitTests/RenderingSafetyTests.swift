import XCTest
@testable import DesignKit

final class RenderingSafetyTests: XCTestCase {
    func testHTMLBlocksNetworkAndBoundsMeasuredHeight() {
        let document = HTMLWebView.document(html: "<img src='https://example.invalid/pixel'>", theme: .sandbox)
        XCTAssertTrue(document.contains("default-src 'none'"))
        XCTAssertTrue(document.contains("img-src data:"))
        XCTAssertTrue(document.contains("form-action 'none'"))
        XCTAssertEqual(HTMLSizing.height(.infinity), 120)
        XCTAssertEqual(HTMLSizing.height(100_000), 1_200)
        XCTAssertEqual(HTMLSizing.height(-10), 44)
    }

}
