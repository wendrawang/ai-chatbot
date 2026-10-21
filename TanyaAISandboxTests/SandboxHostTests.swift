//
//  SandboxHostTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI
import TanyaAI
import UIKit
import XCTest

@testable import Tanya_AI_Sandbox

/// Host tiruan: Tanya AI dibuka dari mana saja lewat `TanyaAIRouter`, stack tetap milik SwiftUI.
@MainActor
final class SandboxHostTests: XCTestCase {
    func testOpensFromAnyScreenFullScreenWithoutRegisteringADestination() async throws {
        let host = try HostHarness()
        defer { host.close() }
        TanyaAIRouter.instance.open()
        await waitUntil { host.page != nil }
        let page = try XCTUnwrap(host.page)
        XCTAssertEqual(page.view.convert(page.view.bounds, to: nil), host.windowBounds)
        TanyaAIRouter.instance.open()
        host.settle()
        XCTAssertEqual(host.navigation?.viewControllers.count, 2)
        TanyaAIRouter.instance.close()
        await waitUntil { host.page == nil && host.navigation?.viewControllers.count == 1 }
        host.probe.destination = DetailCoordinator.named
        await waitUntil { host.navigation?.viewControllers.count == 2 }
        host.settle()
        TanyaAIRouter.instance.open()
        await waitUntil { host.page != nil && host.navigation?.viewControllers.count == 3 }
        TanyaAIRouter.instance.close()
        await waitUntil { host.page == nil }
        XCTAssertEqual(host.probe.destination, DetailCoordinator.named)
        XCTAssertEqual(host.navigation?.viewControllers.count, 2)
    }

    func testSwiftUIPopWhileOpenKeepsTheRouterInSync() async throws {
        let host = try HostHarness()
        defer { host.close() }
        host.probe.destination = DetailCoordinator.named
        await waitUntil { host.navigation?.viewControllers.count == 2 }
        host.settle()
        TanyaAIRouter.instance.open()
        await waitUntil { host.navigation?.viewControllers.count == 3 }
        host.probe.destination = nil
        await waitUntil { host.navigation?.viewControllers.count == 1 && host.page == nil }
        await waitUntil { TanyaAIRouter.instance.presenterID == nil }
        host.settle()
        TanyaAIRouter.instance.open()
        await waitUntil { host.page != nil }
    }

    func testLogoutClosesTanyaAI() async throws {
        let host = try HostHarness()
        defer { host.close() }
        TanyaAIRouter.instance.open()
        await waitUntil { host.page != nil }
        host.appState.state = .prelogin
        await waitUntil { host.page == nil && TanyaAIRouter.instance.presenterID == nil }
    }

    func testOfflineServiceShowsTheHostBlockerAndChatStillGetsTheError() async throws {
        let offline = TanyaAIScreenViewModel(useCase: TanyaAIUseCase(options: SandboxOptions(arguments: ["--offline"])))
        let request = TanyaAIChatRequest(conversationId: "conversation", text: "Halo")
        do {
            for try await _ in offline.useCase.service.streamChat(request) {}
            XCTFail("Service offline harus gagal")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
        }
        await waitUntil { offline.isNetworkUnavailable }
        offline.retry()
        XCTAssertFalse(offline.isNetworkUnavailable)
    }

    func testWebLinkOpensTheHostWebviewInsteadOfSafari() throws {
        let viewModel = TanyaAIScreenViewModel()
        let url = try XCTUnwrap(URL(string: "https://google.com"))
        viewModel.open(.web(url))
        XCTAssertEqual(viewModel.webLink, url)
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
    var page: UIViewController? { Self.chatPage(in: fixture.controller) }

    func settle() {
        fixture.settle()
        fixture.settle()
    }

    func close() {
        TanyaAIRouter.instance.close()
        fixture.close()
    }

    private static func find<Controller: UIViewController>(_ type: Controller.Type, in controller: UIViewController)
        -> Controller?
    {
        if let match = controller as? Controller { return match }
        return controller.children.lazy.compactMap { find(type, in: $0) }.first
    }

    private static func chatPage(in controller: UIViewController) -> UIViewController? {
        if String(describing: Swift.type(of: controller)).contains("ChatScreen") { return controller }
        return controller.children.lazy.compactMap { chatPage(in: $0) }.first
    }
}

private final class DestinationProbe: ObservableObject {
    @Published
    var destination: String?
}

private struct HarnessMain: View {
    @EnvironmentObject
    var appState: AppState
    @ObservedObject
    var probe: DestinationProbe
    @StateObject
    private var viewModel = MainScreenViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                DetailCoordinator(selectionCoordinatorName: $probe.destination)
                Screen { MainScreen(viewModel: viewModel) { probe.destination = DetailCoordinator.named } }
            }
        }
        .navigationViewStyle(.stack)
        .onChange(of: appState.state) { _, state in
            if state != .loggedIn { TanyaAIRouter.instance.close() }
        }
    }
}
