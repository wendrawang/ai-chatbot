import Combine
import Foundation
import TanyaAI

/// Owns the app's deeplink handling, including the hand-off from Tanya AI.
///
/// The sequence is the whole job. The feature is presented full screen over
/// the legacy hierarchy, so a destination cannot be pushed while it is still
/// on screen, and the deeplink has to land on the dashboard first. The router
/// keeps the destination pending until the host says the moment is right.
final class SandboxDeeplinkRouter: ObservableObject {
    /// The destination currently pushed on the legacy stack. `nil` means the
    /// stack is back on the dashboard.
    @Published var activeDestination: SandboxDeeplinkDestination?

    /// Set while a validated destination waits to be pushed.
    @Published private(set) var hasPendingDestination = false

    /// True when the destination must wait for the feature to finish
    /// dismissing. False when the deeplink arrived with nothing presented —
    /// a cold start, or a notification tapped on the dashboard — so the host
    /// can deliver it right away.
    @Published private(set) var awaitsDismissal = false

    private var pendingDestination: SandboxDeeplinkDestination?
    private let opener: (URL) -> Void
    private weak var presenter: TanyaAIPresentationGateway?

    /// - Parameter opener: how to hand a URL to the system. Injected so tests
    ///   can observe it instead of leaving the app.
    init(opener: @escaping (URL) -> Void) {
        self.opener = opener
    }

    /// The presentation gateway to close when a deeplink arrives. Held weakly:
    /// the scene owns both objects.
    func attach(presenter: TanyaAIPresentationGateway) {
        self.presenter = presenter
    }

    /// Handler passed to `TanyaAIModule.makeView(onAction:)`.
    ///
    /// Checks that the link belongs to this app, then opens it so the app
    /// re-enters through its own deeplink entry point. Returns `false` — and
    /// does nothing at all — for anything else.
    @discardableResult
    func handle(_ action: TanyaAIAction) -> Bool {
        guard let url = SandboxDeeplink.accepted(action.deeplink) else {
            return false
        }
        opener(url)
        return true
    }

    /// The single deeplink entry point: cold start, external app, push
    /// notification, and the Tanya AI hand-off all land here.
    ///
    /// Checks the link again — this URL may come from anywhere — resolves it
    /// through the app's dispatcher, then holds the destination and asks the
    /// feature to close if it is on screen.
    @discardableResult
    func receive(_ url: URL) -> Bool {
        guard let accepted = SandboxDeeplink.accepted(url),
              let destination = SandboxDeeplinkDispatcher.destination(
                for: accepted
              ) else {
            return false
        }
        let isFeaturePresented = presenter?.isPresented ?? false
        pendingDestination = destination
        awaitsDismissal = isFeaturePresented
        hasPendingDestination = true

        if isFeaturePresented {
            presenter?.dismissTanyaAI()
        }
        return true
    }

    /// Pushes the pending destination. Call it once the screen is clear: after
    /// the feature finished dismissing and the stack returned to the
    /// dashboard.
    func deliverPendingDestination() {
        guard let destination = pendingDestination else {
            return
        }
        pendingDestination = nil
        hasPendingDestination = false
        awaitsDismissal = false
        activeDestination = destination
    }

    /// Called when the user navigates back, so the pushed destination is not
    /// restored on the next render.
    func clearDestination() {
        activeDestination = nil
    }
}
