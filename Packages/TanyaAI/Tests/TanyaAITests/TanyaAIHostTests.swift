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
            let page = host.makeViewController()
            releasedPage = page
            navigation.pushViewController(page, animated: false)
            page.view.layoutIfNeeded()
            navigation.popViewController(animated: false)
        }
        await waitUntil(timeout: 3) { releasedPage == nil }
    }

    func testLocaleAndPaletteCanChangeAfterCreation() {
        let host = TanyaAIHost(
            customerName: "Lara Croft", service: FakeChatService(), locale: Locale(identifier: "id"),
            onOpenLink: { _ in }
        )
        XCTAssertTrue(host.colors is DefaultColorConstants)
        host.locale = Locale(identifier: "zh-Hans")
        host.colors = PremierColorConstants()
        XCTAssertEqual(host.locale.identifier, "zh-Hans")
        XCTAssertTrue(host.colors is PremierColorConstants)
    }
}
