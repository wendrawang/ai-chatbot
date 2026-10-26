//
//  SandboxHostTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI
import TanyaAI
import Testing
import UIKit

@testable import Tanya_AI_Sandbox

/// Host tiruan: Tanya AI dibuka lewat coordinator host dan tampil sebagai view SwiftUI biasa.
extension HostWindowTests {
    @Test
    func tanyaAIOpensFullScreenAndClosesBackToMain() async throws {
        let host = try HostHarness()
        defer { host.close() }
        host.probe.destination = TanyaAICoordinator.named
        await waitUntil { host.navigation?.viewControllers.count == 2 }
        host.settle()
        let page = try #require(host.navigation?.topViewController)
        #expect(page.view.convert(page.view.bounds, to: nil) == host.windowBounds)
        #expect(Self.textView(in: page.view) != nil, "composer Tanya AI harus ada di halaman yang di-push")
        host.probe.destination = nil
        await waitUntil { host.navigation?.viewControllers.count == 1 }
    }

    @Test
    func parentRerenderKeepsTheOpenPage() async throws {
        let host = try HostHarness()
        defer { host.close() }
        host.probe.destination = TanyaAICoordinator.named
        await waitUntil { host.navigation?.viewControllers.count == 2 }
        host.settle()
        let page = try #require(host.navigation?.topViewController)
        host.probe.tick += 1
        host.settle()
        #expect(host.navigation?.topViewController === page)
        #expect(host.navigation?.viewControllers.count == 2)
    }

    @Test
    func offlineServiceFailsAndShowsTheHostBlocker() async {
        let options = SandboxOptions(arguments: ["--offline"])
        let offline = TanyaAIScreenViewModel(options: options)
        let error = await #expect(throws: URLError.self) { try await offline.useCase.service.start() }
        #expect(error?.code == .notConnectedToInternet)
        await waitUntil { offline.isNetworkUnavailable }
        offline.retry()
        #expect(!offline.isNetworkUnavailable)
    }

    @Test
    func popGestureNeedsAPageToReturnTo() throws {
        let navigation = UINavigationController(rootViewController: UIViewController())
        let fixture = try HostWindowFixture(root: navigation)
        defer { fixture.close() }
        let swipe = try #require(navigation.interactivePopGestureRecognizer)
        #expect(!navigation.gestureRecognizerShouldBegin(swipe))
        navigation.pushViewController(UIViewController(), animated: false)
        fixture.settle()
        #expect(navigation.gestureRecognizerShouldBegin(swipe))
    }
}

private extension HostWindowTests {
    /// Editor composer Tanya AI berupa UITextView, jadi bisa dicari langsung di hierarki halaman.
    static func textView(in root: UIView) -> UITextView? {
        if let textView = root as? UITextView { return textView }
        return root.subviews.lazy.compactMap { textView(in: $0) }.first
    }
}
