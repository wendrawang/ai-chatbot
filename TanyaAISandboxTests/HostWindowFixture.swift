//
//  HostWindowFixture.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 18/10/26.
//

import SwiftUI
import Testing
import UIKit

/// Window nyata pada scene aplikasi, dipakai bersama oleh test navigasi dan layout.
@MainActor
struct HostWindowFixture {
    let controller: UIViewController
    private let window: UIWindow

    init(root: UIViewController) throws {
        let scene = try #require(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        controller = root
        window = UIWindow(windowScene: scene)
        window.rootViewController = root
        window.makeKeyAndVisible()
        settle()
    }

    init(_ content: some View) throws {
        try self.init(root: UIHostingController(rootView: content))
    }

    func settle() {
        controller.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        controller.view.layoutIfNeeded()
    }

    func close() {
        controller.presentedViewController?.dismiss(animated: false)
        window.isHidden = true
        window.rootViewController = nil
        settle()
    }
}
