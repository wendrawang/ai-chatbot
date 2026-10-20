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
    func testPageAndInjectedContentReleaseAfterPopWhileHostStaysOwned() async {
        let host = TanyaAIHost { _ in true }
        let navigation = UINavigationController(rootViewController: UIViewController())
        let window = makeWindow(root: navigation)
        defer { window.isHidden = true }
        weak var releasedOwner: NSObject?
        weak var releasedPage: UIViewController?
        do {
            let owner = NSObject()
            releasedOwner = owner
            let page = host.makeViewController { Text(owner.description) }
            releasedPage = page
            navigation.pushViewController(page, animated: false)
            page.view.layoutIfNeeded()
            navigation.popViewController(animated: false)
        }
        let released = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in releasedOwner == nil && releasedPage == nil }, object: nil
        )
        await fulfillment(of: [released], timeout: 3)
    }

    func testLocaleAndPaletteApplyWhenPageIsCreatedAndChangesWaitForNextPage() {
        var host = TanyaAIHost(locale: Locale(identifier: "id"), colors: PremierColorConstants()) { _ in true }
        let openedProbe = EnvironmentProbe()
        let openedWindow = makeWindow(root: host.makeViewController { EnvironmentReader(probe: openedProbe) })
        defer { openedWindow.isHidden = true }
        XCTAssertTrue(openedProbe.colors is PremierColorConstants)
        XCTAssertEqual(openedProbe.locale?.identifier, "id")
        host.locale = Locale(identifier: "zh-Hans")
        host.colors = PrivateColorConstants()
        let nextProbe = EnvironmentProbe()
        let nextWindow = makeWindow(root: host.makeViewController { EnvironmentReader(probe: nextProbe) })
        defer { nextWindow.isHidden = true }
        XCTAssertTrue(nextProbe.colors is PrivateColorConstants)
        XCTAssertEqual(nextProbe.locale?.identifier, "zh-Hans")
        openedWindow.rootViewController?.view.layoutIfNeeded()
        XCTAssertTrue(openedProbe.colors is PremierColorConstants)
        XCTAssertEqual(openedProbe.locale?.identifier, "id")
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
