import Foundation
import SwiftUI
import TanyaAI

/// The whole hand-off, in one screen.
///
/// Assumes what most apps already have: a deeplink handler that takes a URL,
/// returns to the dashboard, and opens the destination. If yours does that,
/// there is nothing to build — only something to sequence.
struct MinimalDeeplinkRootScreen: View {
    let dependencies: TanyaAIDependencies

    @State private var showsTanyaAI = false
    /// Held, not opened. The feature covers the screen, so the deeplink has to
    /// wait for it to go away.
    @State private var pendingDeeplink: URL?

    var body: some View {
        NavigationView {
            List {
                Button("Open Tanya AI") {
                    showsTanyaAI = true
                }
            }
            .navigationBarTitle("Dashboard")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(
            isPresented: $showsTanyaAI,
            onDismiss: openPendingDeeplink
        ) {
            TanyaAIModule.makeView(
                dependencies: dependencies,
                onClose: { showsTanyaAI = false },
                onAction: handle
            )
        }
    }

    /// Runs when a bubble hands over a deeplink.
    ///
    /// Two checks — the scheme and the entry host — are enough to reject
    /// `https://…`, `tel:`, and links into other apps. What the link means
    /// beyond that is your existing handler's job.
    private func handle(_ action: TanyaAIAction) {
        guard let url = URL(string: action.deeplink),
              url.scheme == "ocbcid",
              url.host == "mobile" else {
            return
        }
        pendingDeeplink = url
        showsTanyaAI = false
    }

    /// Runs after the feature finished dismissing, which is the earliest
    /// moment the deeplink can navigate. Your handler already returns to the
    /// dashboard first, so nothing else is needed here.
    private func openPendingDeeplink() {
        guard let url = pendingDeeplink else {
            return
        }
        pendingDeeplink = nil
        AppDeeplinkHandler.open(url)
    }
}

/// The deeplink entry point your app already has — the one your
/// `SceneDelegate` calls from `scene(_:openURLContexts:)`.
///
/// Replace this with the real one.
enum AppDeeplinkHandler {
    static func open(_ url: URL) {}
}
