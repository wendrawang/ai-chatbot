import DesignKit
import SwiftUI
import WebKit

struct DemoHostWebScreen: View {
    let url: URL
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            DemoHostHeader(title: "Webview dalam aplikasi", onClose: onClose)
            Text(url.absoluteString)
                .designFont(.caption)
                .padding(FigmaSize.spacing16.scaledToArtwork)
                .accessibilityIdentifier("sandbox.webview.url")
            DemoOfflineWebView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, FigmaSize.spacing16.scaledToArtwork)
        .background(Color.white)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sandbox.webview.screen")
    }
}

struct DemoHostDestinationScreen: View {
    let url: URL
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: FigmaSize.spacing16.scaledToArtwork) {
            DemoHostHeader(title: "Halaman existing host", onClose: onClose)
            Text("Deeplink diterima oleh host").designFont(.headline)
            Text(url.absoluteString)
                .designFont(.body)
                .accessibilityIdentifier("sandbox.deeplink.url")
            Spacer()
        }
        .padding(.horizontal, FigmaSize.spacing16.scaledToArtwork)
        .background(Color.white)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sandbox.deeplink.screen")
    }
}

/// The demo renders local HTML so routing tests work without network access.
/// Production host pages load their validated URL using the application's own webview policy.
private struct DemoOfflineWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.accessibilityIdentifier = "sandbox.webview"
        view.loadHTMLString(
            """
            <html><head><meta name="viewport" content="width=device-width, initial-scale=1"></head>
            <body><h2>Halaman demo offline</h2><p>Link dibuka di webview dalam aplikasi, tanpa Safari.</p></body></html>
            """, baseURL: nil
        )
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {}

    static func dismantleUIView(_ view: WKWebView, coordinator: Void) {
        view.stopLoading()
        view.navigationDelegate = nil
    }
}
