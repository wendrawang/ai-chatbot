import SwiftUI
import TanyaAI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var presentationGateway: TanyaAIPresentationGateway?

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
    }

    private func makeRootController(
        for launchMode: SandboxLaunchMode
    ) -> UIViewController {
        let gateway = makeGateway(for: launchMode)
        presentationGateway = gateway

        if launchMode.isStandaloneFeature {
            return UIHostingController(rootView: gateway.makeView())
        }
        return UIHostingController(
            rootView: LegacyRootScreen(tanyaAIPresenter: gateway)
        )
    }

    private func makeGateway(
        for launchMode: SandboxLaunchMode
    ) -> TanyaAIPresentationGateway {
        let dependencies = SandboxTanyaAIFactory.makeDependencies(
            showsShowcase: launchMode.isStandaloneFeature
        )
        return TanyaAIPresentationGateway(
            dependencies: dependencies,
            configuration: TanyaAIConfiguration(
                initialPrompt: launchMode.initialPrompt
            )
        )
    }
}
