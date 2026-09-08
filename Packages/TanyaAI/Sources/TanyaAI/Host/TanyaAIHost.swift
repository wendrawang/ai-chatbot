import Foundation
import TanyaAIContracts
import TanyaAIDesignSystem
import UIKit

/// The whole of the host's integration surface.
///
/// One object to create, one modifier to apply, one method to call:
///
/// ```swift
/// let tanyaAI = TanyaAIHost(
///     theme: .sandbox,
///     deeplinkScheme: "ocbcid",
///     deeplinkHost: "mobile",
///     makeSession: { SendbirdChatSessionAdapter(botUserId: "cet-bot") },
///     onDeeplink: { url in DeeplinkManager.instance.openUrlScheme(url) }
/// )
///
/// NavigationView { ... }
///     .tanyaAIHost(tanyaAI)
///
/// Button("Tanya AI") { tanyaAI.present() }
/// ```
///
/// Create it where the signed-in session lives, not in a `View`: a `View` is a
/// value that SwiftUI rebuilds whenever it likes, and a presentation must not
/// depend on that.
public final class TanyaAIHost {
    private let theme: TanyaAITheme
    private let authorizationService: TanyaAIAuthorizationService?
    private let deeplinkScheme: String
    private let deeplinkHost: String?
    private let initialPrompt: String?
    private let makeSession: () -> TanyaAIChatSession
    private let onDeeplink: (URL) -> Void

    private weak var anchor: UIViewController?
    private weak var presented: UIViewController?

    /// True while the feature is on screen.
    public var isPresenting: Bool {
        presented != nil
    }

    /// - Parameters:
    ///   - authorizationService: runs the in-feature PIN sheet. Only a
    ///     confirmation with no `handoff` reaches it, so a host whose
    ///     confirmations all open its own flows leaves this nil.
    ///   - deeplinkScheme: the only scheme a bubble may hand back. Anything
    ///     else is dropped, which is what stops a reply from sending the
    ///     customer to `https://…` or into another application.
    ///   - deeplinkHost: pins the link to one entry point. Nil accepts any
    ///     host under the scheme.
    ///   - makeSession: called once per presentation. It must return a *new*
    ///     session each time: the feature takes ownership of the session's
    ///     callback and closes it on dismissal, so a shared instance would be
    ///     torn out from under the next presentation.
    ///   - onDeeplink: the host's existing deeplink handler - the same one
    ///     `scene(_:openURLContexts:)` calls. It is invoked only after the
    ///     feature has finished dismissing.
    public init(
        theme: TanyaAITheme,
        authorizationService: TanyaAIAuthorizationService? = nil,
        deeplinkScheme: String,
        deeplinkHost: String? = nil,
        initialPrompt: String? = nil,
        makeSession: @escaping () -> TanyaAIChatSession,
        onDeeplink: @escaping (URL) -> Void
    ) {
        self.theme = theme
        self.authorizationService = authorizationService
        self.deeplinkScheme = deeplinkScheme
        self.deeplinkHost = deeplinkHost
        self.initialPrompt = initialPrompt
        self.makeSession = makeSession
        self.onDeeplink = onDeeplink
    }

    /// Opens the feature over the screen carrying `tanyaAIHost(_:)`.
    ///
    /// Does nothing if it is already open, or before the modifier has been
    /// applied to a screen that is on screen.
    public func present() {
        guard presented == nil, let anchor else {
            return
        }
        let controller = TanyaAIModule.makeViewController(
            configuration: TanyaAIConfiguration(initialPrompt: initialPrompt),
            dependencies: TanyaAIDependencies(
                chatSession: makeSession(),
                authorizationService: authorizationService,
                theme: theme
            ),
            onAction: { [weak self] action in
                self?.handle(action)
            }
        )
        presented = controller
        anchor.present(controller, animated: true)
    }

    /// Closes the feature. `completion` runs once the screen is clear.
    public func dismiss(completion: (() -> Void)? = nil) {
        guard let controller = presented else {
            completion?()
            return
        }
        presented = nil
        controller.dismiss(animated: true, completion: completion)
    }

    func attach(anchor: UIViewController) {
        self.anchor = anchor
    }

    /// A bubble handed back a deeplink.
    ///
    /// The order is the point. The destination opens on the host's own
    /// dashboard, so it has to wait until the feature is gone - and waiting is
    /// the dismissal completion, never a timer. A push that starts while a
    /// modal is still animating away is dropped without an error.
    private func handle(_ action: TanyaAIAction) {
        guard let url = accepted(action.deeplink) else {
            return
        }
        dismiss { [weak self] in
            self?.onDeeplink(url)
        }
    }

    /// The security boundary, and deliberately the whole of it.
    ///
    /// The scheme check rejects `https://…`, `tel:`, and anything that would
    /// launch a different application. What the link means past that is the
    /// host's existing handler's business; a second parser here would only
    /// drift from it.
    private func accepted(_ deeplink: String) -> URL? {
        guard let url = URL(string: deeplink),
              url.scheme == deeplinkScheme else {
            return nil
        }
        guard let deeplinkHost else {
            return url
        }
        return url.host == deeplinkHost ? url : nil
    }
}
