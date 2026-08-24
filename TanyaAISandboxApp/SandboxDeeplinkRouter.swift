import Combine
import Foundation
import TanyaAI

/// Turns a Tanya AI action into the host's own deeplink, then replays the
/// arrival exactly like an external one.
///
/// The sequence matters. The feature is presented full screen over the legacy
/// hierarchy, so the destination cannot be pushed while it is still on screen.
/// The router keeps the destination pending, asks the presenter to close, and
/// only delivers once the presentation is gone.
final class SandboxDeeplinkRouter: ObservableObject {
    /// The destination currently pushed on the legacy stack.
    @Published var activeDestination: SandboxDeeplinkDestination?
    /// Set while a destination waits for the right moment to be pushed.
    @Published private(set) var hasPendingDestination = false
    /// True when the destination must wait for the feature to finish
    /// dismissing. False when the deeplink arrived with nothing presented, so
    /// the host can deliver it right away.
    @Published private(set) var awaitsDismissal = false

    private var pendingDestination: SandboxDeeplinkDestination?
    private let opener: (URL) -> Void
    private weak var presenter: TanyaAIPresentationGateway?

    init(opener: @escaping (URL) -> Void) {
        self.opener = opener
    }

    func attach(presenter: TanyaAIPresentationGateway) {
        self.presenter = presenter
    }

    /// Called by the feature. Maps the action to a route, builds the URL, and
    /// hands it to the system so the app re-enters through its own deeplink
    /// entry point.
    @discardableResult
    func handle(_ action: TanyaAIAction) -> Bool {
        guard let route = SandboxDeeplinkRoute(rawValue: action.route) else {
            return false
        }
        let destination = SandboxDeeplinkDestination(
            route: route,
            parameters: action.parameters
        )
        guard let url = SandboxDeeplink.url(for: destination) else {
            return false
        }
        opener(url)
        return true
    }

    /// The single deeplink entry point: cold start, external app, push
    /// notification, and the Tanya AI hand-off all land here.
    @discardableResult
    func receive(_ url: URL) -> Bool {
        guard let destination = SandboxDeeplink.destination(from: url) else {
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

    /// Called once the full-screen presentation has finished dismissing.
    func deliverPendingDestination() {
        guard let destination = pendingDestination else {
            return
        }
        pendingDestination = nil
        hasPendingDestination = false
        awaitsDismissal = false
        activeDestination = destination
    }

    func clearDestination() {
        activeDestination = nil
    }
}
