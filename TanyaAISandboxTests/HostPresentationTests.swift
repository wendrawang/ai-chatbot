//
//  HostPresentationTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI
import UIKit
import XCTest

@testable import TanyaAI

@MainActor
final class HostPresentationTests: XCTestCase {
    func testOffscreenRequestsAndEmptyDismissAreSafe() {
        let host = TanyaAIHost { _ in true }
        host.present()
        XCTAssertFalse(host.isPresenting)
        let anchor = UIViewController()
        host.attach(anchor: anchor, locale: Locale(identifier: "id"))
        host.present()
        XCTAssertFalse(host.isPresenting)
        var completionCount = 0
        host.dismiss { completionCount += 1 }
        XCTAssertEqual(completionCount, 1)
    }

    func testPresentationIsFullScreenAndLeavesHostNavigationIntact() async throws {
        let host = TanyaAIHost { _ in true }
        let fixture = try HostWindowFixture(
            NavigationView { Text("Host") }.navigationViewStyle(.stack).tanyaAIHost(host)
        )
        defer { fixture.close() }
        let navigation = try XCTUnwrap(fixture.navigationController())
        let stack = navigation.viewControllers
        host.present()
        await fixture.waitForPresentation()
        let presented = try XCTUnwrap(fixture.controller.presentedViewController)
        XCTAssertTrue(host.isPresenting)
        XCTAssertEqual(presented.modalPresentationStyle, .fullScreen)
        XCTAssertNotNil(presented.transitioningDelegate as? TanyaAIPushTransition)
        host.present()
        XCTAssertTrue(fixture.controller.presentedViewController === presented)
        XCTAssertEqual(navigation.viewControllers, stack)
        let dismissed = expectation(description: "Feature dismissed before host continues")
        host.dismiss { dismissed.fulfill() }
        await fulfillment(of: [dismissed], timeout: 2)
        fixture.settle()
        XCTAssertFalse(host.isPresenting)
        XCTAssertNil(fixture.controller.presentedViewController)
        XCTAssertEqual(navigation.viewControllers, stack)
        host.present()
        await fixture.waitForPresentation()
        XCTAssertTrue(host.isPresenting)
        XCTAssertFalse(fixture.controller.presentedViewController === presented)
    }

    func testDoesNotPresentOverAnotherHostModal() throws {
        let host = TanyaAIHost { _ in true }
        let fixture = try HostWindowFixture(Text("Host").tanyaAIHost(host))
        defer { fixture.close() }
        let other = UIViewController()
        fixture.controller.present(other, animated: false)
        fixture.settle()
        host.present()
        XCTAssertFalse(host.isPresenting)
        XCTAssertTrue(fixture.controller.presentedViewController === other)
    }

    func testHostAndFeatureReleaseAfterDismissAndTeardown() async throws {
        weak var releasedHost: TanyaAIHost?
        weak var releasedFeature: UIViewController?
        do {
            let host = TanyaAIHost { _ in true }
            let fixture = try HostWindowFixture(Text("Host").tanyaAIHost(host))
            host.present()
            await fixture.waitForPresentation()
            XCTAssertTrue(host.isPresenting)
            releasedHost = host
            releasedFeature = fixture.controller.presentedViewController
            let dismissed = expectation(description: "Dismiss before releasing owners")
            host.dismiss { dismissed.fulfill() }
            await fulfillment(of: [dismissed], timeout: 2)
            fixture.close()
        }
        let released = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in releasedHost == nil && releasedFeature == nil }, object: nil
        )
        await fulfillment(of: [released], timeout: 2)
        XCTAssertNil(releasedHost)
        XCTAssertNil(releasedFeature)
    }
}

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

    func waitForPresentation() async {
        if let transition = controller.presentedViewController?.transitionCoordinator {
            let completed = XCTestExpectation(description: "UIKit completed presentation")
            transition.animate(alongsideTransition: nil) { _ in completed.fulfill() }
            let result = await XCTWaiter.fulfillment(of: [completed], timeout: 2)
            XCTAssertEqual(result, .completed)
        }
        settle()
    }

    func navigationController() -> UINavigationController? {
        findNavigation(in: controller)
    }

    private func findNavigation(in controller: UIViewController) -> UINavigationController? {
        if let navigation = controller as? UINavigationController { return navigation }
        return controller.children.lazy.compactMap { self.findNavigation(in: $0) }.first
    }
}
