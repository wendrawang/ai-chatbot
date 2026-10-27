//
//  TanyaAIHostTests.swift
//  TanyaAI
//
//  Created by Wendra on 18/10/26.
//

import DesignKit
import SwiftUI
import Testing
import UIKit

@testable import TanyaAI

/// Berurutan karena test async membuka window dan menunggu di antaranya.
@MainActor
@Suite(.serialized)
struct TanyaAIHostTests {
    @Test
    func pageOpensTheSessionAndClosesTheStreamWhenReleased() async {
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
        #expect(startCount == 1)
    }

    @Test
    func localeAndPaletteApplyWhenPageIsCreatedAndChangesWaitForNextPage() {
        var host = TanyaAIHost(
            locale: Locale(identifier: "id"), colors: PremierColorConstants(), service: FakeChatService())
        var opened: (colors: any FigmaColorProtocol, locale: Locale)?
        let openedWindow = makeWindow(
            root: UIHostingController(rootView: host.applyingSettings(to: EnvironmentReader { opened = ($0, $1) })))
        defer { openedWindow.isHidden = true }
        #expect(opened?.colors is PremierColorConstants)
        #expect(opened?.locale.identifier == "id")
        host.locale = Locale(identifier: "zh-Hans")
        host.colors = PrivateColorConstants()
        var next: (colors: any FigmaColorProtocol, locale: Locale)?
        let nextWindow = makeWindow(
            root: UIHostingController(rootView: host.applyingSettings(to: EnvironmentReader { next = ($0, $1) })))
        defer { nextWindow.isHidden = true }
        #expect(next?.colors is PrivateColorConstants)
        #expect(next?.locale.identifier == "zh-Hans")
        openedWindow.rootViewController?.view.layoutIfNeeded()
        #expect(opened?.colors is PremierColorConstants)
        #expect(opened?.locale.identifier == "id")
    }

    private func makeWindow(root: UIViewController) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = root
        window.makeKeyAndVisible()
        root.view.layoutIfNeeded()
        return window
    }
}
