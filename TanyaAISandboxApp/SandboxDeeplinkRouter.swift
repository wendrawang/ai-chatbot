import Combine
import Foundation
import TanyaAI

/// Owns the app's deeplink handling, including the hand-off from Tanya AI.
///
/// The sequence is the whole job. The feature is presented modally over the
/// legacy hierarchy, so a destination cannot be pushed while it is still on
/// screen, and the deeplink has to land on the dashboard first. UIKit gives
/// the exact moment for free: the dismissal completion handler.
final class SandboxDeeplinkRouter: ObservableObject {
    /// The destination currently pushed on the legacy stack. `nil` means the
    /// stack is back on the dashboard.
    @Published var activeDestination: SandboxDeeplinkDestination?

    /// Set while a validated destination waits to be pushed.
    @Published private(set) var hasPendingDestination = false

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

    /// Handler passed to `TanyaAIModule.makeViewController(onAction:)`.
    ///
    /// Validates the deeplink the response sent, then opens it so the app
    /// re-enters through its own deeplink entry point. Returns `false` - and
    /// does nothing at all - when the deeplink is not one this app accepts.
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
    /// Holds the destination, then closes the feature and waits for the
    /// dismissal to finish before delivering it.
    @discardableResult
    func receive(_ url: URL) -> Bool {
        guard let accepted = SandboxDeeplink.accepted(url),
              let destination = SandboxDeeplinkDispatcher.destination(
                for: accepted
              ) else {
            return false
        }
        pendingDestination = destination
        hasPendingDestination = true

        guard let presenter, presenter.isPresenting else {
            deliverPendingDestination()
            return true
        }
        presenter.dismissTanyaAI { [weak self] in
            self?.deliverPendingDestination()
        }
        return true
    }

    /// Pushes the pending destination. Called once the screen is clear.
    func deliverPendingDestination() {
        guard let destination = pendingDestination else {
            return
        }
        pendingDestination = nil
        hasPendingDestination = false
        activeDestination = destination
    }

    /// Called when the customer navigates back, so the pushed destination is
    /// not restored on the next render.
    func clearDestination() {
        activeDestination = nil
    }
}
