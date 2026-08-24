import SwiftUI
import TanyaAI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var presentationGateway: TanyaAIPresentationGateway?
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
        let gateway = makeGateway(for: launchMode)
        presentationGateway = gateway

        if launchMode.isStandaloneFeature {
            return UIHostingController(rootView: gateway.makeView())
        }

        let router = makeDeeplinkRouter(gateway: gateway)
        deeplinkRouter = router
        return UIHostingController(
            rootView: LegacyRootScreen(
                tanyaAIPresenter: gateway,
                deeplinkRouter: router
            )
        )
    }

    /// The action never opens anything itself. It asks the host for a route,
    /// the host builds its own URL, and the app re-enters through the same
    /// deeplink entry point an external caller would use.
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

    private func makeGateway(
        for launchMode: SandboxLaunchMode
    ) -> TanyaAIPresentationGateway {
        let dependencies = SandboxTanyaAIFactory.makeDependencies(
            showsShowcase: launchMode.usesFastStreaming
        )
        return TanyaAIPresentationGateway(
            dependencies: dependencies,
            configuration: TanyaAIConfiguration(
                initialPrompt: launchMode.initialPrompt
            )
        )
    }
}
