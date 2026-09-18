import SwiftUI
import UIKit
import WebKit

/// A web view that renders one static fragment and nothing else.
///
/// Three locks, all of them deliberate in a banking app:
///
/// - **JavaScript is off.** Content arriving from a backend must not be able
///   to run code inside the application.
/// - **Navigation is refused.** Only the initial load is allowed; a tap on a
///   link, a redirect, a form post - all cancelled. Nothing in a chat bubble
///   should be able to take over the screen.
/// - **The fragment is loaded with no base URL**, so a relative reference has
///   nowhere to resolve to.
///
/// Height is measured from the scroll view rather than asked for with
/// JavaScript, which would defeat the first lock.
struct HTMLWebView: UIViewRepresentable {
    let html: String
    let theme: Theme
    let onHeightChange: (CGFloat) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onHeightChange: onHeightChange)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        // The bubble scrolls, not the fragment inside it.
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        // The fragment's own tree is hidden from assistive technology, and
        // the bubble announces `accessibilityText` instead. Reading raw
        // table markup aloud helps nobody, and leaving the tree exposed also
        // slows every accessibility query in the conversation - enough to
        // push the screenshot test past its budget when this was added.
        webView.accessibilityElementsHidden = true
        context.coordinator.observe(webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let document = Self.document(html: html, theme: theme)
        guard context.coordinator.loadedDocument != document else {
            return
        }
        context.coordinator.load(document, in: webView)
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.stopLoading()
        webView.navigationDelegate = nil
        coordinator.stopObserving()
    }

    /// Wraps the fragment in the host's own colours and type.
    ///
    /// Without this the fragment ignores the theme entirely and a dark-mode
    /// conversation gets a white rectangle in the middle of it.
    static func document(html: String, theme: Theme) -> String {
        let text = theme.colors.primaryText.cssColor
        let secondary = theme.colors.secondaryText.cssColor
        let divider = theme.colors.divider.cssColor
        let size = theme.fonts.body.pointSize
        return """
        <!doctype html><html><head><meta charset="utf-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <style>
        :root { color-scheme: light dark; }
        html, body { margin: 0; padding: 0; background: transparent; }
        body {
          font: \(size)px -apple-system, system-ui, sans-serif;
          color: \(text);
          -webkit-text-size-adjust: none;
        }
        table { border-collapse: collapse; width: 100%; }
        th, td {
          padding: 8px 12px;
          border-bottom: 1px solid \(divider);
          text-align: left;
        }
        th { color: \(secondary); font-weight: 600; }
        img { max-width: 100%; height: auto; }
        </style></head><body>\(html)</body></html>
        """
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private(set) var loadedDocument: String?
        private var isInitialNavigationPending = false
        private let onHeightChange: (CGFloat) -> Void
        private var observation: NSKeyValueObservation?

        init(onHeightChange: @escaping (CGFloat) -> Void) {
            self.onHeightChange = onHeightChange
            super.init()
        }

        func load(_ document: String, in webView: WKWebView) {
            loadedDocument = document
            isInitialNavigationPending = true
            webView.loadHTMLString(document, baseURL: nil)
        }

        /// Watches the rendered height instead of asking for it, because
        /// asking would mean running script.
        func observe(_ webView: WKWebView) {
            observation = webView.scrollView.observe(
                \.contentSize,
                options: [.new]
            ) { [onHeightChange] _, change in
                guard let height = change.newValue?.height, height > 0 else {
                    return
                }
                onHeightChange(height)
            }
        }

        func stopObserving() {
            observation?.invalidate()
            observation = nil
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            // `.other` also includes automatic redirects and frame loads.
            // Only the main-frame about:blank load armed by the host may pass.
            guard isInitialNavigationPending,
                  navigationAction.navigationType == .other,
                  navigationAction.targetFrame?.isMainFrame == true,
                  navigationAction.request.url?.absoluteString == "about:blank" else {
                decisionHandler(.cancel)
                return
            }
            isInitialNavigationPending = false
            decisionHandler(.allow)
        }
    }
}

private extension UIColor {
    /// Resolved against the current traits, because a dynamic colour means
    /// nothing to a stylesheet.
    var cssColor: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        resolvedColor(with: .current).getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        let channel = { (value: CGFloat) in Int((value * 255).rounded()) }
        return "rgba(\(channel(red)),\(channel(green)),"
            + "\(channel(blue)),\(alpha))"
    }
}
