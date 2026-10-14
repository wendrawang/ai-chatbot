import Combine
import DesignKit
import Foundation
import TanyaAIContracts
import TanyaAIDomain
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
///     makeSession: makeChatSession,
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
///
/// It is an `ObservableObject` carrying no published state, purely so a host
/// can inject it with `.environmentObject(_:)`. A coordinator written as
/// `MainCoordinator()` deep inside a root screen has no initializer to thread
/// anything through, and that is the common shape.
@MainActor
public final class TanyaAIHost: ObservableObject {
    private let theme: Theme
    private let themeProvider: (() -> Theme)?
    private let deeplinkScheme: String
    private let deeplinkHost: String?
    private let initialPrompt: String?
    private let copy: CopyCatalog
    private let welcome: WelcomeConfiguration?
    private let makeSession: () -> TanyaAIChatSession
    private let makeNewSession: (() -> TanyaAIChatSession)?
    private let onHostFlow: TanyaAIHostFlowHandler?
    private let onDestination: ((Action, URL) -> Void)?
    private let onDeeplink: (URL) -> Void

    private weak var anchor: UIViewController?
    private weak var presented: UIViewController?

    /// True while the feature is on screen.
    public var isPresenting: Bool {
        presented != nil
    }

    /// Create one host outside the view body. Session factories return a fresh adapter per conversation.
    /// onHostFlow presents existing document/PIN pages above chat and returns their result.
    /// onDestination handles webview destinations; onDeeplink receives validated application routes.
    public init(
        theme: Theme,
        themeProvider: (() -> Theme)? = nil,
        deeplinkScheme: String,
        deeplinkHost: String? = nil,
        initialPrompt: String? = nil,
        copy: CopyCatalog = CopyCatalog(),
        welcome: WelcomeConfiguration? = nil,
        makeSession: @escaping () -> TanyaAIChatSession,
        makeNewSession: (() -> TanyaAIChatSession)? = nil,
        onDestination: ((Action, URL) -> Void)? = nil,
        onHostFlow: TanyaAIHostFlowHandler? = nil,
        onDeeplink: @escaping (URL) -> Void
    ) {
        self.onDestination = onDestination
        self.theme = theme
        self.themeProvider = themeProvider
        self.deeplinkScheme = deeplinkScheme
        self.deeplinkHost = deeplinkHost
        self.initialPrompt = initialPrompt
        self.copy = copy
        self.welcome = welcome
        self.makeSession = makeSession
        self.makeNewSession = makeNewSession
        self.onHostFlow = onHostFlow
        self.onDeeplink = onDeeplink
    }

    /// A presentation is a theme snapshot; changing the app theme applies on the next opening.
    var presentationTheme: Theme { themeProvider?() ?? theme }

    /// Opens the feature over the screen carrying `tanyaAIHost(_:)`.
    ///
    /// Does nothing if it is already open, or before the modifier has been
    /// applied to a screen that is on screen.
    public func present() {
        guard presented == nil, let anchor else {
            return
        }
        let controller = TanyaAIModule.makeViewController(
            configuration: TanyaAIConfiguration(
                initialPrompt: initialPrompt,
                copy: copy,
                welcome: welcome
            ),
            dependencies: TanyaAIDependencies(
                chatSession: makeSession(),
                theme: presentationTheme
            ),
            onHostFlow: onHostFlow,
            makeNewSession: makeNewSession,
            onAction: { [weak self] action in self?.handle(action) }
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
    private func handle(_ action: Action) {
        guard let url = accepted(action) else {
            return
        }
        dismiss { [weak self] in
            guard let self else { return }
            if let onDestination = self.onDestination {
                onDestination(action, url)
            } else {
                self.onDeeplink(url)
            }
        }
    }

    /// The host still validates HTTPS domains before routing a webview intent.
    func accepted(_ action: Action) -> URL? {
        if action.destinationType != .deeplink {
            guard onDestination != nil, let url = URL(string: action.deeplink),
                url.scheme == "https", url.host != nil, url.user == nil, url.password == nil
            else { return nil }
            return url
        }
        guard let url = URL(string: action.deeplink),
            url.scheme == deeplinkScheme
        else {
            return nil
        }
        guard let deeplinkHost else {
            return url
        }
        return url.host == deeplinkHost ? url : nil
    }
}
