//
//  HostWindowFixture.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 18/10/26.
//

import SwiftUI
import Testing
import UIKit

/// Induk semua suite yang memakai window scene aplikasi. Swift Testing menjalankan test paralel,
/// jadi suite di dalamnya dibuat berurutan agar window dan run loop tidak saling bertabrakan.
@Suite(.serialized)
enum HostWindowTests {}

/// Window nyata pada scene aplikasi, dipakai bersama oleh test navigasi dan layout.
@MainActor
final class HostWindowFixture {
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

    convenience init(_ content: some View) throws {
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

    /// Meniru host yang mengganti root window, misalnya main ke prelogin saat logout.
    func replaceRoot(with root: UIViewController) {
        window.rootViewController = root
        settle()
    }
}
