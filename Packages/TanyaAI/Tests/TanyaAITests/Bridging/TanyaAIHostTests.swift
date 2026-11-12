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
    func pageAndInjectedContentReleaseAfterPopWhileHostStaysOwned() async {
        let host = TanyaAIHost(bridge: TanyaAIBridge(transport: FakeChatTransport()))
        let navigation = UINavigationController(rootViewController: UIViewController())
        let window = makeWindow(root: navigation)
        defer { window.isHidden = true }
        weak var releasedOwner: NSObject?
        weak var releasedPage: UIViewController?
        do {
            let owner = NSObject()
            releasedOwner = owner
            let page = UIHostingController(rootView: host.makeView { Text(owner.description) })
            releasedPage = page
            navigation.pushViewController(page, animated: false)
            page.view.layoutIfNeeded()
            navigation.popViewController(animated: false)
        }
        await waitUntil { releasedOwner == nil && releasedPage == nil }
    }

    @Test
    func localeAndPaletteApplyWhenPageIsCreatedAndChangesWaitForNextPage() {
        var host = TanyaAIHost(
            locale: Locale(identifier: "id"),
            colors: PremierColorConstants(),
            bridge: TanyaAIBridge(transport: FakeChatTransport())
        )
        var opened: (colors: any FigmaColorProtocol, locale: Locale)?
        let openedWindow = makeWindow(
            root: UIHostingController(rootView: host.makeView { EnvironmentReader { opened = ($0, $1) } })
        )
        defer { openedWindow.isHidden = true }
        #expect(opened?.colors is PremierColorConstants)
        #expect(opened?.locale.identifier == "id")
        host.locale = Locale(identifier: "zh-Hans")
        host.colors = PrivateColorConstants()
        var next: (colors: any FigmaColorProtocol, locale: Locale)?
        let nextWindow = makeWindow(
            root: UIHostingController(rootView: host.makeView { EnvironmentReader { next = ($0, $1) } })
        )
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
