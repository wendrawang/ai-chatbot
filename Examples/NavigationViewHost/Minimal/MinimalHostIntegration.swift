import TanyaAI
import SwiftUI
import UIKit

/// Everything the host has to change, in one file.
///
/// Two additions to the existing scene delegate and one button on the
/// existing screen. No composition type, no protocol of your own.
final class MinimalSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var presenter: MinimalTanyaAIPresenter?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        // Built once per scene, never inside a SwiftUI body.
        let dependencies = TanyaAIDependencies(
            streamingTransport: MinimalTanyaAITransport(
                client: AppNetworking.shared.streamingClient
            ),
            authorizationService: MinimalTanyaAIAuthorization(
                api: AppNetworking.shared.authorizationAPI
            ),
            // Bootstrap value. Replace with the host theme before release:
            // see Production/HostTanyaAITheme.swift.
            theme: .sandbox
        )

        let presenter = MinimalTanyaAIPresenter(dependencies: dependencies)
        let rootController = UIHostingController(
            rootView: MinimalRootScreen(presenter: presenter)
        )
        presenter.attach(rootController: rootController)
        self.presenter = presenter

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootController
        window.makeKeyAndVisible()
        self.window = window
    }
}

/// Presents the feature from the host's own controller.
///
/// One presentation at a time, and a fresh feature graph each time: the
/// factory is called on every present, never cached.
final class MinimalTanyaAIPresenter {
    private weak var rootController: UIViewController?
    private weak var activeController: UIViewController?
    private let dependencies: TanyaAIDependencies

    init(dependencies: TanyaAIDependencies) {
        self.dependencies = dependencies
    }

    func attach(rootController: UIViewController) {
        self.rootController = rootController
    }

    func presentTanyaAI() {
        guard activeController == nil, let rootController else {
            return
        }
        let controller = TanyaAIModule.makeViewController(
            dependencies: dependencies
        )
        activeController = controller
        rootController.present(controller, animated: true)
    }
}

/// The existing `NavigationView` screen, plus one button.
///
/// Tanya AI is presented as its own controller rather than pushed, so the
/// legacy stack and the feature's internal navigation never mix.
struct MinimalRootScreen: View {
    let presenter: MinimalTanyaAIPresenter

    var body: some View {
        NavigationView {
            List {
                Button("Open Tanya AI") {
                    presenter.presentTanyaAI()
                }
            }
            .navigationBarTitle("Dashboard")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
