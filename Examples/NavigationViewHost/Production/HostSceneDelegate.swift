import SwiftUI
import UIKit

/// The existing scene delegate, with the composition root added.
///
/// The scene owns the composition and the presenter, so both live exactly as
/// long as the window. Nothing else in the lifecycle changes.
final class HostSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var composition: HostTanyaAIComposition?
    private var presenter: HostTanyaAIPresenter?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let composition = HostTanyaAIComposition(
            requestFactory: AppRequestFactory.shared,
            authorizing: AppTransactionAuthorizer.shared,
            sessionConfiguration: AppNetworking.shared.streamingConfiguration,
            securityDelegate: AppNetworking.shared.pinningValidator,
            messagePath: "/v1/chat/messages"
        )
        let presenter = composition.makePresenter()
        self.composition = composition
        self.presenter = presenter

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(
            rootView: HostRootScreen(
                presenter: presenter,
                composition: composition
            )
        )
        window.makeKeyAndVisible()
        self.window = window
    }
}
