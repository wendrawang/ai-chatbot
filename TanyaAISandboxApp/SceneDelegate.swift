import TanyaAI
import SwiftUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var tanyaAIGateway: TanyaAIPresentationGateway?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let showsShowcase = ProcessInfo.processInfo.arguments.contains(
            "--showcase"
        )
        let rootController = makeRootController(
            showsShowcase: showsShowcase
        )

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootController
        window.makeKeyAndVisible()
        self.window = window
    }

    private func makeRootController(
        showsShowcase: Bool
    ) -> UIViewController {
        let dependencies = SandboxTanyaAIFactory.makeDependencies(
            showsShowcase: showsShowcase
        )
        if showsShowcase {
            return TanyaAIModule.makeViewController(
                configuration: TanyaAIConfiguration(
                    initialPrompt: "showcase all bubbles"
                ),
                dependencies: dependencies
            )
        }
        return makeLegacyRootController(dependencies: dependencies)
    }

    private func makeLegacyRootController(
        dependencies: TanyaAIDependencies
    ) -> UIViewController {
        let gateway = TanyaAIPresentationGateway(
            dependencies: dependencies,
            configuration: TanyaAIConfiguration()
        )
        let rootScreen = LegacyRootScreen(
            tanyaAIPresenter: gateway
        )
        let rootController = UIHostingController(rootView: rootScreen)
        gateway.attach(rootController: rootController)
        tanyaAIGateway = gateway
        return rootController
    }
}
