//
//  SceneDelegate.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 18/10/26.
//

import SwiftUI
import UIKit

/// Root window meniru host SwiftUI: `RootScreen` dengan prelogin dan main coordinator.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let appState = AppState()

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let root = RootScreen(appState: appState)
            .environment(\.locale, SandboxOptions.current.locale ?? .current)
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: root)
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()
        self.window = window
    }
}
