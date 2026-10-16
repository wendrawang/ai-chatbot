//
//  SceneDelegate.swift
//  TanyaAIHarness
//
//  Created by Wendra on 16/10/26.
//

import TanyaAIHarnessSupport
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate
{
    var window: UIWindow?
    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions)
    {
        guard let scene = scene as? UIWindowScene
        else
        {
            return
        }

        let window = UIWindow(windowScene: scene)
        window.rootViewController = HarnessRootViewController(arguments: ProcessInfo.processInfo.arguments)
        window.makeKeyAndVisible()
        self.window = window
    }
}
