import WebKit
import XCTest
@testable import DesignKit

/// Exercise WebKit's actual navigation classifications: automatic redirects
/// and frame loads are `.other`, just like loadHTMLString.
@MainActor
final class HTMLNavigationTests: XCTestCase {
    func testHostCanLoadAndReplaceAFragment() {
        let probe = HTMLNavigationProbe()
        let webView = makeWebView(probe: probe)

        for text in ["First result", "Updated result"] {
            let finished = expectation(description: text)
            probe.onFinish = { finished.fulfill() }
            probe.coordinator.load("<p>\(text)</p>", in: webView)
            wait(for: [finished], timeout: 10)
        }

        XCTAssertEqual(probe.allowedLoads, 2)
    }

    func testAutomaticRedirectCannotLeaveTheFragment() {
        assertNavigationBlocked(
            html: "<meta http-equiv='refresh' content='0;url=https://example.invalid/redirect'>",
            target: "https://example.invalid/redirect"
        )
    }

    func testAutomaticRedirectCannotReloadBlankPage() {
        assertNavigationBlocked(
            html: "<meta http-equiv='refresh' content='0;url=about:blank'>",
            target: "about:blank",
            navigationType: .reload
        )
    }

    func testChildFrameCannotLoadEvenABlankPage() {
        assertNavigationBlocked(
            html: "<iframe src='about:blank'></iframe>",
            target: "about:blank"
        )
    }

    private func assertNavigationBlocked(
        html: String,
        target: String,
        navigationType: WKNavigationType = .other
    ) {
        let probe = HTMLNavigationProbe()
        let webView = makeWebView(probe: probe)
        let attempted = expectation(description: "Fragment navigation refused")
        probe.onSubsequentNavigation = { action, policy in
            XCTAssertEqual(action.request.url?.absoluteString, target)
            XCTAssertEqual(action.navigationType, navigationType)
            XCTAssertEqual(policy, .cancel)
            attempted.fulfill()
        }

        probe.coordinator.load(html, in: webView)
        wait(for: [attempted], timeout: 10)
        XCTAssertEqual(probe.allowedLoads, 1)
    }

    private func makeWebView(probe: HTMLNavigationProbe) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        configuration.websiteDataStore = .nonPersistent()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = probe
        return webView
    }
}

@MainActor
private final class HTMLNavigationProbe: NSObject, WKNavigationDelegate {
    let coordinator = HTMLWebView.Coordinator(onHeightChange: { _ in })
    var allowedLoads = 0
    var onFinish: (() -> Void)?
    var onSubsequentNavigation: ((WKNavigationAction, WKNavigationActionPolicy) -> Void)?

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        coordinator.webView(webView, decidePolicyFor: navigationAction) { policy in
            if self.allowedLoads > 0, let callback = self.onSubsequentNavigation {
                callback(navigationAction, policy)
                // Never make an external request even if the policy regresses.
                decisionHandler(.cancel)
                return
            }
            if policy == .allow {
                self.allowedLoads += 1
            }
            decisionHandler(policy)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onFinish?()
    }
}
