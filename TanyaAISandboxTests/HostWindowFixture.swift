//
//  HostWindowFixture.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 18/10/26.
//

import SwiftUI
import UIKit
import XCTest

/// Window nyata pada scene aplikasi, dipakai bersama oleh test presentasi, lifecycle dan layout.
@MainActor
final class HostWindowFixture {
    let controller: UIViewController
    private let window: UIWindow

    init(_ content: some View) throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        controller = UIHostingController(rootView: content)
        window = UIWindow(windowScene: scene)
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

    /// Meniru host UIKit yang mengganti root window, misalnya main ke prelogin.
    func replaceRoot(with root: UIViewController) {
        window.rootViewController = root
        settle()
    }

    func waitForPresentation() async {
        if let transition = controller.presentedViewController?.transitionCoordinator {
            let completed = XCTestExpectation(description: "UIKit completed presentation")
            transition.animate(alongsideTransition: nil) { _ in completed.fulfill() }
            let result = await XCTWaiter.fulfillment(of: [completed], timeout: 2)
            XCTAssertEqual(result, .completed)
        }
        settle()
    }

    func navigationController(in controller: UIViewController? = nil) -> UINavigationController? {
        findNavigation(in: controller ?? self.controller)
    }

    private func findNavigation(in controller: UIViewController) -> UINavigationController? {
        if let navigation = controller as? UINavigationController { return navigation }
        return controller.children.lazy.compactMap { self.findNavigation(in: $0) }.first
    }
}
