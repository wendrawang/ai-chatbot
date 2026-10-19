//
//  RevampNavigationTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 18/10/26.
//

import SwiftUI
import TanyaAI
import UIKit
import XCTest

@testable import Tanya_AI_Sandbox

@MainActor
final class RevampNavigationTests: XCTestCase {
    func testSwipeBackIsNativeAndOnlyActiveWhenThereIsAPageToReturnTo() throws {
        let navigation = RevampNavigationController(rootViewController: UIHostingController(rootView: Text("Main")))
        let fixture = try HostWindowFixture(root: navigation)
        defer { fixture.close() }
        let swipe = try XCTUnwrap(navigation.interactivePopGestureRecognizer)
        XCTAssertTrue(navigation.isNavigationBarHidden)
        XCTAssertTrue(swipe.isEnabled)
        XCTAssertFalse(navigation.gestureRecognizerShouldBegin(swipe))
        navigation.pushViewController(
            TanyaAIHost(customerName: "Lara Croft", service: SandboxChatService()) { _ in }.makeViewController(),
            animated: false)
        fixture.settle()
        XCTAssertTrue(navigation.gestureRecognizerShouldBegin(swipe))
    }

    func testRouterPushesOnePageAndAllowsReopeningAfterPop() async throws {
        let router = SandboxRouter(options: SandboxOptions(arguments: []))
        let navigation = RevampNavigationController(rootViewController: UIHostingController(rootView: Text("Main")))
        router.navigation = navigation
        let fixture = try HostWindowFixture(root: navigation)
        defer { fixture.close() }
        router.openTanyaAI()
        router.openTanyaAI()
        await waitUntil { navigation.transitionCoordinator == nil }
        XCTAssertEqual(navigation.viewControllers.count, 2)
        navigation.popViewController(animated: false)
        // Halaman lama dilepas setelah pop; baru setelah itu router boleh membuka lagi.
        await waitUntil {
            router.openTanyaAI()
            return navigation.viewControllers.count == 2
        }
    }

    func testNoInternetBlockerPresentsOverTanyaAI() throws {
        let navigation = RevampNavigationController(rootViewController: UIHostingController(rootView: Text("Main")))
        let fixture = try HostWindowFixture(root: navigation)
        defer { fixture.close() }
        navigation.pushViewController(
            TanyaAIHost(customerName: "Lara Croft", service: SandboxChatService()) { _ in }.makeViewController(),
            animated: false)
        fixture.settle()
        let blocker = UIViewController()
        blocker.modalPresentationStyle = .overFullScreen
        navigation.present(blocker, animated: false)
        fixture.settle()
        XCTAssertTrue(navigation.presentedViewController === blocker)
        XCTAssertNotNil(blocker.view.window)
    }

    func testSessionExpiredSheetFromMainShowsOverTanyaAI() async throws {
        let session = BlockerState()
        let main = UIHostingController(rootView: MainWithSessionSheet(session: session))
        let navigation = RevampNavigationController(rootViewController: main)
        let fixture = try HostWindowFixture(root: navigation)
        defer { fixture.close() }
        navigation.pushViewController(
            TanyaAIHost(customerName: "Lara Croft", service: SandboxChatService()) { _ in }.makeViewController(),
            animated: false)
        fixture.settle()
        session.isExpired = true
        let shown = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in navigation.presentedViewController?.view.window != nil }, object: nil
        )
        await fulfillment(of: [shown], timeout: 3)
    }

    func testReplacingTheWindowRootForPreloginReleasesTanyaAI() async throws {
        let navigation = RevampNavigationController(rootViewController: UIHostingController(rootView: Text("Main")))
        let fixture = try HostWindowFixture(root: navigation)
        defer { fixture.close() }
        weak var page: UIViewController?
        do {
            let pushed = TanyaAIHost(customerName: "Lara Croft", service: SandboxChatService()) { _ in }
                .makeViewController()
            page = pushed
            navigation.pushViewController(pushed, animated: false)
            fixture.settle()
        }
        fixture.replaceRoot(with: UIHostingController(rootView: Text("Prelogin")))
        let released = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in page?.view.window == nil }, object: nil
        )
        await fulfillment(of: [released], timeout: 3)
    }
}

private extension RevampNavigationTests {
    func waitUntil(_ condition: @escaping () -> Bool) async {
        let met = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in condition() }, object: nil)
        await fulfillment(of: [met], timeout: 3)
    }
}

private final class BlockerState: ObservableObject {
    @Published
    var isExpired = false
}

/// Main legacy yang menampilkan bottom sheet session expired dari view-nya sendiri.
private struct MainWithSessionSheet: View {
    @ObservedObject
    var session: BlockerState

    var body: some View {
        Text("Main").sheet(isPresented: $session.isExpired) { Text("Session expired") }
    }
}
