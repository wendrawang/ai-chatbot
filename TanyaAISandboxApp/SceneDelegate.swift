import TanyaAI
import SwiftUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var tanyaAIGateway: TanyaAIPresentationGateway?
    private var deeplinkRouter: SandboxDeeplinkRouter?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let launchMode = SandboxLaunchMode(
            arguments: ProcessInfo.processInfo.arguments
        )
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeRootController(for: launchMode)
        window.makeKeyAndVisible()
        self.window = window

        connectionOptions.urlContexts.forEach { context in
            deeplinkRouter?.receive(context.url)
        }
    }

    /// Deeplinks that arrive while the app is running, including the one the
    /// hand-off just opened.
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        URLContexts.forEach { context in
            deeplinkRouter?.receive(context.url)
        }
    }

    private func makeRootController(
        for launchMode: SandboxLaunchMode
    ) -> UIViewController {
        let dependencies = SandboxTanyaAIFactory.makeDependencies(
            showsShowcase: launchMode.usesFastStreaming
        )

        if launchMode.isStandaloneFeature {
            return TanyaAIModule.makeViewController(
                configuration: TanyaAIConfiguration(
                    initialPrompt: launchMode.initialPrompt
                ),
                dependencies: dependencies
            )
        }
        return makeLegacyRootController(
            dependencies: dependencies,
            launchMode: launchMode
        )
    }

    private func makeLegacyRootController(
        dependencies: TanyaAIDependencies,
        launchMode: SandboxLaunchMode
    ) -> UIViewController {
        let gateway = TanyaAIPresentationGateway(
            dependencies: dependencies,
            configuration: TanyaAIConfiguration(
                initialPrompt: launchMode.initialPrompt
            )
        )
        let router = makeDeeplinkRouter(gateway: gateway)
        let rootScreen = LegacyRootScreen(
            tanyaAIPresenter: gateway,
            deeplinkRouter: router
        )
        let rootController = UIHostingController(rootView: rootScreen)
        gateway.attach(rootController: rootController)
        tanyaAIGateway = gateway
        deeplinkRouter = router
        return rootController
    }

    /// Wires the hand-off. The feature reports a deeplink, this router checks
    /// it belongs to the app and opens it, and the app re-enters through the
    /// same entry point an external caller would use.
    private func makeDeeplinkRouter(
        gateway: TanyaAIPresentationGateway
    ) -> SandboxDeeplinkRouter {
        let router = SandboxDeeplinkRouter { url in
            UIApplication.shared.open(url)
        }
        router.attach(presenter: gateway)
        gateway.onAction { [weak router] action in
            router?.handle(action)
        }
        return router
    }
}
