import SwiftUI
import TanyaAI
import TanyaAIDesignSystem
import UIKit

/// Everything the host has to change, in one file.
///
/// Two additions to the existing scene delegate, one `@State` and one
/// modifier on the existing screen. No presentation gateway, no composition
/// type, no protocol of your own.
final class MinimalSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

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

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(
            rootView: MinimalRootScreen(dependencies: dependencies)
        )
        window.makeKeyAndVisible()
        self.window = window
    }
}

/// The existing `NavigationView` screen, plus one modifier.
///
/// `fullScreenCover` sits on the `NavigationView`, not inside it, and Tanya AI
/// is never a `NavigationLink` destination.
struct MinimalRootScreen: View {
    let dependencies: TanyaAIDependencies
    @State private var showsTanyaAI = false

    var body: some View {
        NavigationView {
            List {
                Button("Open Tanya AI") {
                    showsTanyaAI = true
                }
            }
            .navigationBarTitle("Home")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showsTanyaAI) {
            TanyaAIModule.makeView(
                dependencies: dependencies,
                onClose: {
                    showsTanyaAI = false
                }
            )
        }
    }
}
