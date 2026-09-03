import SwiftUI
import UIKit

/// Wiring the hand-off into an existing `NavigationView` host.
///
/// Nothing changes in the screen itself: the feature is presented as its own
/// controller, and the deeplink is delivered by the bridge once that
/// controller has finished dismissing. The scene owns both objects.
final class HostDeeplinkSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let composition = AppTanyaAIComposition.make()
    private var presenter: HostTanyaAIPresenter?
    private var bridge: HostDeeplinkBridge?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        // `composition` is the host's own composition root - see
        // Production/HostTanyaAIComposition.swift.
        let presenter = composition.makePresenter()
        let bridge = HostDeeplinkBridge(
            presenter: presenter,
            dispatch: { url in
                AppDeeplinkHandler.open(url)
            }
        )
        presenter.onAction { [weak bridge] action in
            bridge?.handle(action)
        }

        let rootController = UIHostingController(
            rootView: HostRootScreen(presenter: presenter)
        )
        presenter.attach(rootController: rootController)
        self.presenter = presenter
        self.bridge = bridge

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootController
        window.makeKeyAndVisible()
        self.window = window

        connectionOptions.urlContexts.forEach { context in
            bridge.receive(context.url)
        }
    }

    /// Deeplinks that arrive while the app is running, including the one the
    /// hand-off just opened.
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        URLContexts.forEach { context in
            bridge?.receive(context.url)
        }
    }
}

/// Stand-in for wherever your app builds its composition root.
enum AppTanyaAIComposition {
    static func make() -> HostTanyaAIComposition {
        fatalError("Replace with the host's own composition root")
    }
}
