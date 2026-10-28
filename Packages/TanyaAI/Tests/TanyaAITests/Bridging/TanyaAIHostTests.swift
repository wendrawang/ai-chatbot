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
        let host = TanyaAIHost { _ in true }
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
        var host = TanyaAIHost(locale: Locale(identifier: "id"), colors: PremierColorConstants()) { _ in true }
        let openedProbe = EnvironmentProbe()
        let openedWindow = makeWindow(
            root: UIHostingController(rootView: host.makeView { EnvironmentReader(probe: openedProbe) }))
        defer { openedWindow.isHidden = true }
        #expect(openedProbe.colors is PremierColorConstants)
        #expect(openedProbe.locale?.identifier == "id")
        host.locale = Locale(identifier: "zh-Hans")
        host.colors = PrivateColorConstants()
        let nextProbe = EnvironmentProbe()
        let nextWindow = makeWindow(
            root: UIHostingController(rootView: host.makeView { EnvironmentReader(probe: nextProbe) }))
        defer { nextWindow.isHidden = true }
        #expect(nextProbe.colors is PrivateColorConstants)
        #expect(nextProbe.locale?.identifier == "zh-Hans")
        openedWindow.rootViewController?.view.layoutIfNeeded()
        #expect(openedProbe.colors is PremierColorConstants)
        #expect(openedProbe.locale?.identifier == "id")
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
