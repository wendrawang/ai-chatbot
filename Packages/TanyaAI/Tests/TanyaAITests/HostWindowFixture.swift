//
//  HostWindowFixture.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI
import UIKit

/// Layout-only fixture for testing the optional anchor without presenting a modal.
@MainActor
final class HostWindowFixture {
    let controller: UIViewController
    private let window: UIWindow

    init(_ content: some View) {
        controller = UIHostingController(rootView: content)
        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        settle()
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
