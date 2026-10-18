//
//  SceneDelegate.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 18/10/26.
//

import SwiftUI
import UIKit

/// Root window host: jalur navigasi bersih (`RevampNavigationController`) dengan main legacy sebagai root.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var router: SandboxRouter?

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let options = SandboxOptions(arguments: ProcessInfo.processInfo.arguments)
        let router = SandboxRouter(options: options)
        let main = UIHostingController(
            rootView: SandboxHostView { [weak router] in router?.openTanyaAI() }
                .environment(\.locale, options.locale ?? .current)
        )
        let navigation = RevampNavigationController(rootViewController: main)
        router.navigation = navigation
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigation
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()
        self.window = window
        self.router = router
    }
}
