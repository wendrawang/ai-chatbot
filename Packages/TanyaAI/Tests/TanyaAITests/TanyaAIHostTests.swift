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
    func testPageOpensTheSessionAndClosesTheStreamWhenReleased() async {
        let service = FakeChatService()
        let host = TanyaAIHost(service: service)
        let navigation = UINavigationController(rootViewController: UIViewController())
        let window = makeWindow(root: navigation)
        defer { window.isHidden = true }
        weak var releasedPage: UIViewController?
        do {
            let page = UIHostingController(rootView: host.makeView())
            releasedPage = page
            navigation.pushViewController(page, animated: false)
            page.view.layoutIfNeeded()
            await waitUntil { await service.openedStreams == 1 }
            navigation.popViewController(animated: false)
        }
        await waitUntil { releasedPage == nil }
        await waitUntil { await service.closedStreams == 1 }
        let startCount = await service.startCount
        XCTAssertEqual(startCount, 1)
    }

    func testLocaleAndPaletteApplyWhenPageIsCreatedAndChangesWaitForNextPage() {
        var host = TanyaAIHost(
            locale: Locale(identifier: "id"), colors: PremierColorConstants(), service: FakeChatService())
        let openedProbe = EnvironmentProbe()
        let openedWindow = makeWindow(
            root: UIHostingController(rootView: host.applyingSettings(to: EnvironmentReader(probe: openedProbe))))
        defer { openedWindow.isHidden = true }
        XCTAssertTrue(openedProbe.colors is PremierColorConstants)
        XCTAssertEqual(openedProbe.locale?.identifier, "id")
        host.locale = Locale(identifier: "zh-Hans")
        host.colors = PrivateColorConstants()
        let nextProbe = EnvironmentProbe()
        let nextWindow = makeWindow(
            root: UIHostingController(rootView: host.applyingSettings(to: EnvironmentReader(probe: nextProbe))))
        defer { nextWindow.isHidden = true }
        XCTAssertTrue(nextProbe.colors is PrivateColorConstants)
        XCTAssertEqual(nextProbe.locale?.identifier, "zh-Hans")
        openedWindow.rootViewController?.view.layoutIfNeeded()
        XCTAssertTrue(openedProbe.colors is PremierColorConstants)
        XCTAssertEqual(openedProbe.locale?.identifier, "id")
    }

    private func waitUntil(_ condition: () async -> Bool) async {
        let deadline = Date().addingTimeInterval(3)
        while Date() < deadline {
            if await condition() { return }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        XCTFail("Kondisi tidak terpenuhi")
    }

    private func makeWindow(root: UIViewController) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = root
        window.makeKeyAndVisible()
        root.view.layoutIfNeeded()
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
