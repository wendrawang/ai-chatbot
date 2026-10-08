import WebKit
import XCTest
@testable import DesignKit

@MainActor
final class HTMLLifecycleTests: XCTestCase {
    func testObservationDoesNotKeepCoordinatorAlive() {
        let webView = WKWebView()
        weak var released: HTMLWebView.Coordinator?
        autoreleasepool {
            let coordinator = HTMLWebView.Coordinator(onHeightChange: { _ in })
            coordinator.observe(webView)
            released = coordinator
        }
        XCTAssertNil(released)
    }

    func testObservationUsesLatestCallbackAndStopsAfterDismantle() {
        let webView = WKWebView()
        var firstHeight: CGFloat = 0
        var secondHeight: CGFloat = 0
        let coordinator = HTMLWebView.Coordinator { firstHeight = $0 }
        coordinator.observe(webView)
        webView.scrollView.contentSize = CGSize(width: 300, height: 100)
        XCTAssertEqual(firstHeight, 100)
        coordinator.onHeightChange = { secondHeight = $0 }
        webView.scrollView.contentSize = CGSize(width: 300, height: 200)
        XCTAssertEqual(firstHeight, 100)
        XCTAssertEqual(secondHeight, 200)
        coordinator.stopObserving()
        webView.scrollView.contentSize = CGSize(width: 300, height: 300)
        XCTAssertEqual(secondHeight, 200)
    }

    func testFittingViewportCannotInflateContentHeight() {
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 300, height: 100_000))
        var measuredHeights: [CGFloat] = []
        let coordinator = HTMLWebView.Coordinator { measuredHeights.append($0) }
        coordinator.observe(webView)
        webView.scrollView.contentSize = webView.bounds.size
        XCTAssertTrue(measuredHeights.isEmpty)

        webView.frame.size.height = 180
        webView.scrollView.contentSize = CGSize(width: 300, height: 220)
        XCTAssertEqual(measuredHeights, [220])
        coordinator.stopObserving()
    }
}
