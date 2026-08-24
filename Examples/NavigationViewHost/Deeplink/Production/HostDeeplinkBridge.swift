import Combine
import Foundation
import TanyaAI
import UIKit

/// Bridges a Tanya AI hand-off to the deeplink handler the app already has.
///
/// It does not parse deeplinks and does not navigate. Its whole job is timing:
/// the feature is presented full screen, so a deeplink that navigates
/// underneath it would be lost. The bridge holds the URL until the screen is
/// clear, then hands it to the existing handler.
final class HostDeeplinkBridge: ObservableObject {
    /// Set while a validated deeplink waits to be opened.
    @Published private(set) var hasPendingDeeplink = false

    /// True when the deeplink must wait for the feature to finish dismissing.
    /// False when it arrived with nothing presented — a cold start, or a
    /// notification tapped on the dashboard — so it can be delivered at once.
    @Published private(set) var awaitsDismissal = false

    private var pendingDeeplink: URL?
    private weak var presenter: HostTanyaAIPresenter?
    private let dispatch: (URL) -> Void
    private let open: (URL) -> Void

    /// - Parameters:
    ///   - presenter: the feature's presentation state, closed before a
    ///     deeplink navigates.
    ///   - dispatch: the app's existing deeplink handler — the same function
    ///     `scene(_:openURLContexts:)` calls. It already returns to the
    ///     dashboard and opens the destination.
    ///   - open: how to hand a URL to the system. Injected so a unit test can
    ///     observe it instead of leaving the app.
    init(
        presenter: HostTanyaAIPresenter,
        dispatch: @escaping (URL) -> Void,
        open: @escaping (URL) -> Void = { UIApplication.shared.open($0) }
    ) {
        self.presenter = presenter
        self.dispatch = dispatch
        self.open = open
    }

    /// Handler passed to `TanyaAIModule.makeView(onAction:)`.
    ///
    /// Checks that the link belongs to this app, then opens it so the hand-off
    /// re-enters through the same path a push notification uses. Returns
    /// `false` — and does nothing — for anything else.
    @discardableResult
    func handle(_ action: TanyaAIAction) -> Bool {
        guard let url = accepted(action.deeplink) else {
            return false
        }
        // Round-trip through the system. Calling `receive(url)` directly works
        // too and is easier to test; the rest is identical.
        open(url)
        return true
    }

    /// The single deeplink entry point: cold start, push notification,
    /// external app, and the Tanya AI hand-off all land here.
    ///
    /// Holds the URL and asks the feature to close if it is on screen.
    @discardableResult
    func receive(_ url: URL) -> Bool {
        guard let url = accepted(url) else {
            return false
        }
        let isPresented = presenter?.isPresented ?? false
        pendingDeeplink = url
        awaitsDismissal = isPresented
        hasPendingDeeplink = true

        if isPresented {
            presenter?.dismissTanyaAI()
        }
        return true
    }

    /// Hands the pending URL to the app's own handler. Call it once the screen
    /// is clear — from `fullScreenCover(onDismiss:)`, or straight away when
    /// nothing was presented.
    func deliverPendingDeeplink() {
        guard let url = pendingDeeplink else {
            return
        }
        pendingDeeplink = nil
        hasPendingDeeplink = false
        awaitsDismissal = false
        dispatch(url)
    }

    /// The security boundary, and deliberately the whole of it.
    ///
    /// The scheme check is the one that matters: it rejects `https://…`,
    /// `tel:`, and links that would launch a different app. The host check
    /// pins the link to the app's deeplink entry point. What the link means
    /// past that is the existing handler's business — it already knows, and a
    /// second parser here would only drift from it.
    private func accepted(_ deeplink: String) -> URL? {
        guard let url = URL(string: deeplink) else {
            return nil
        }
        return accepted(url)
    }

    private func accepted(_ url: URL) -> URL? {
        guard url.scheme == "ocbcid", url.host == "mobile" else {
            return nil
        }
        return url
    }
}
