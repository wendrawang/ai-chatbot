//
//  SandboxHostTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI
import UIKit
import XCTest

@testable import Tanya_AI_Sandbox

/// Host tiruan: Tanya AI dibuka lewat coordinator host dan tampil sebagai view SwiftUI biasa.
@MainActor
final class SandboxHostTests: XCTestCase {
    func testTanyaAIOpensFullScreenAndClosesBackToMain() async throws {
        let host = try HostHarness()
        defer { host.close() }
        host.probe.destination = TanyaAICoordinator.named
        await waitUntil { host.navigation?.viewControllers.count == 2 }
        host.settle()
        let page = try XCTUnwrap(host.navigation?.topViewController)
        XCTAssertEqual(page.view.convert(page.view.bounds, to: nil), host.windowBounds)
        XCTAssertNotNil(Self.textView(in: page.view), "composer Tanya AI harus ada di halaman yang di-push")
        host.probe.destination = nil
        await waitUntil { host.navigation?.viewControllers.count == 1 }
    }

    func testParentRerenderKeepsTheOpenPage() async throws {
        let host = try HostHarness()
        defer { host.close() }
        host.probe.destination = TanyaAICoordinator.named
        await waitUntil { host.navigation?.viewControllers.count == 2 }
        host.settle()
        let page = try XCTUnwrap(host.navigation?.topViewController)
        host.probe.tick += 1
        host.settle()
        XCTAssertTrue(host.navigation?.topViewController === page)
        XCTAssertEqual(host.navigation?.viewControllers.count, 2)
    }

    func testRejectedOrOfflineSendKeepsDraftAndOfflineShowsTheHostBlocker() {
        XCTAssertTrue(TanyaAIUseCase(options: SandboxOptions(arguments: [])).send("Halo"))
        XCTAssertFalse(TanyaAIUseCase(options: SandboxOptions(arguments: ["--reject-send"])).send("Halo"))
        let offline = TanyaAIScreenViewModel(useCase: TanyaAIUseCase(options: SandboxOptions(arguments: ["--offline"])))
        XCTAssertFalse(offline.useCase.send("Halo"))
        XCTAssertTrue(offline.isNetworkUnavailable)
        offline.retry()
        XCTAssertFalse(offline.isNetworkUnavailable)
    }

    func testPopGestureNeedsAPageToReturnTo() throws {
        let navigation = UINavigationController(rootViewController: UIViewController())
        let fixture = try HostWindowFixture(root: navigation)
        defer { fixture.close() }
        let swipe = try XCTUnwrap(navigation.interactivePopGestureRecognizer)
        XCTAssertFalse(navigation.gestureRecognizerShouldBegin(swipe))
        navigation.pushViewController(UIViewController(), animated: false)
        fixture.settle()
        XCTAssertTrue(navigation.gestureRecognizerShouldBegin(swipe))
    }
}

private extension SandboxHostTests {
    /// Editor composer Tanya AI berupa UITextView, jadi bisa dicari langsung di hierarki halaman.
    static func textView(in root: UIView) -> UITextView? {
        if let textView = root as? UITextView { return textView }
        return root.subviews.lazy.compactMap { textView(in: $0) }.first
    }

    func waitUntil(_ condition: @escaping () -> Bool) async {
        let met = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in condition() }, object: nil)
        await fulfillment(of: [met], timeout: 3)
    }
}

/// Main tiruan dengan destinasi detail yang dikendalikan test.
@MainActor
private final class HostHarness {
    let appState = AppState()
    let probe = DestinationProbe()
    private let fixture: HostWindowFixture

    init() throws {
        fixture = try HostWindowFixture(HarnessMain(probe: probe).environmentObject(appState))
        settle()
    }

    var windowBounds: CGRect { fixture.controller.view.window?.bounds ?? .zero }
    var navigation: UINavigationController? { Self.find(UINavigationController.self, in: fixture.controller) }

    func settle() {
        fixture.settle()
        fixture.settle()
    }

    func close() {
        fixture.close()
    }

    private static func find<Controller: UIViewController>(_ type: Controller.Type, in controller: UIViewController)
        -> Controller?
    {
        if let match = controller as? Controller { return match }
        return controller.children.lazy.compactMap { find(type, in: $0) }.first
    }
}

private final class DestinationProbe: ObservableObject {
    @Published
    var destination: String?
    @Published
    var tick = 0
}

/// Sama dengan `MainCoordinator`, tetapi tujuan dikendalikan test.
private struct HarnessMain: View {
    @ObservedObject
    var probe: DestinationProbe
    @StateObject
    private var viewModel = MainScreenViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if probe.destination == TanyaAICoordinator.named {
                    TanyaAICoordinator(selectionCoordinatorName: $probe.destination)
                }
                Screen { MainScreen(viewModel: viewModel, onOpenDetail: {}, onOpenTanyaAI: {}) }
                Text(String(probe.tick))
            }
        }
        .navigationViewStyle(.stack)
    }
}
