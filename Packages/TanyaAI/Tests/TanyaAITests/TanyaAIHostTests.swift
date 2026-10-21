//
//  TanyaAIHostTests.swift
//  TanyaAI
//
//  Created by Wendra on 18/10/26.
//

import DesignKit
import SwiftUI
import UIKit
import XCTest

@testable import TanyaAI

@MainActor
final class TanyaAIHostTests: XCTestCase {
    func testPageReleasesAfterPopWhileHostAndServiceStayOwned() async {
        let service = FakeChatService()
        let host = TanyaAIHost(customerName: "Lara Croft", service: service) { _ in }
        let navigation = UINavigationController(rootViewController: UIViewController())
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        weak var releasedPage: UIViewController?
        do {
            let page = UIHostingController(rootView: host.makeView())
            releasedPage = page
            navigation.pushViewController(page, animated: false)
            page.view.layoutIfNeeded()
            navigation.popViewController(animated: false)
        }
        await waitUntil(timeout: 3) { releasedPage == nil }
    }

    func testLocaleAndPaletteApplyWhenPageIsCreatedAndChangesWaitForNextPage() {
        var host = TanyaAIHost(
            customerName: "Lara Croft", service: FakeChatService(), locale: Locale(identifier: "id"),
            colors: PremierColorConstants(), onOpenLink: { _ in }
        )
        let openedProbe = EnvironmentProbe()
        let openedWindow = makeWindow(root: host.applyingSettings(to: EnvironmentReader(probe: openedProbe)))
        defer { openedWindow.isHidden = true }
        XCTAssertTrue(openedProbe.colors is PremierColorConstants)
        XCTAssertEqual(openedProbe.locale?.identifier, "id")
        host.locale = Locale(identifier: "zh-Hans")
        host.colors = PrivateColorConstants()
        let nextProbe = EnvironmentProbe()
        let nextWindow = makeWindow(root: host.applyingSettings(to: EnvironmentReader(probe: nextProbe)))
        defer { nextWindow.isHidden = true }
        XCTAssertTrue(nextProbe.colors is PrivateColorConstants)
        XCTAssertEqual(nextProbe.locale?.identifier, "zh-Hans")
        openedWindow.rootViewController?.view.layoutIfNeeded()
        XCTAssertTrue(openedProbe.colors is PremierColorConstants)
        XCTAssertEqual(openedProbe.locale?.identifier, "id")
    }

    private func makeWindow(root: some View) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = UIHostingController(rootView: root)
        window.makeKeyAndVisible()
        window.rootViewController?.view.layoutIfNeeded()
        return window
    }
}

private final class EnvironmentProbe {
    var colors: (any FigmaColorProtocol)?
    var locale: Locale?
}

private struct EnvironmentReader: View {
    @Environment(\.designColors)
    private var colors
    @Environment(\.locale)
    private var locale
    let probe: EnvironmentProbe

    var body: some View {
        probe.colors = colors
        probe.locale = locale
        return Text("Content")
    }
}
