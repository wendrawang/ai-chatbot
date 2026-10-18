//
//  AppDelegate.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 18/10/26.
//

import DesignKit
import UIKit

/// Meniru host: AppDelegate + SceneDelegate. Font package didaftarkan sekali saat bootstrap.
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        do { try FontFace.registerFonts() } catch {
            assertionFailure(SandboxOptions.fontFailure + String(describing: error))
        }
        return true
    }

    func application(
        _ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
