//
//  HostPresentationTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI
import UIKit
import XCTest

@testable import TanyaAI

@MainActor
final class HostPresentationTests: XCTestCase {
    func testOffscreenRequestsAndEmptyDismissAreSafe() {
        let host = TanyaAIHost { _ in true }
        host.present()
        XCTAssertFalse(host.isPresenting)
        let anchor = UIViewController()
        host.attach(anchor: anchor)
        host.present()
        XCTAssertFalse(host.isPresenting)
        var completionCount = 0
        host.dismiss { completionCount += 1 }
        XCTAssertEqual(completionCount, 1)
    }

    func testPresentationCoversHostAndLeavesHostNavigationIntact() async throws {
        let host = TanyaAIHost { _ in true }
        let fixture = try HostWindowFixture(
            NavigationView { Text("Host") }.navigationViewStyle(.stack).tanyaAIHost(host)
        )
        defer { fixture.close() }
        let navigation = try XCTUnwrap(fixture.navigationController())
        let stack = navigation.viewControllers
        host.present()
        await fixture.waitForPresentation()
        let presented = try XCTUnwrap(fixture.controller.presentedViewController)
        XCTAssertTrue(host.isPresenting)
        XCTAssertEqual(presented.modalPresentationStyle, .overFullScreen)
        XCTAssertTrue(fixture.controller.view.isHidden)
        XCTAssertNotNil(presented.transitioningDelegate as? TanyaAIPushTransition)
        XCTAssertNil(fixture.navigationController(in: presented))
        host.present()
        XCTAssertTrue(fixture.controller.presentedViewController === presented)
        XCTAssertEqual(navigation.viewControllers, stack)
        let dismissed = expectation(description: "Feature dismissed before host continues")
        host.dismiss { dismissed.fulfill() }
        await fulfillment(of: [dismissed], timeout: 2)
        fixture.settle()
        XCTAssertFalse(host.isPresenting)
        XCTAssertNil(fixture.controller.presentedViewController)
        XCTAssertEqual(navigation.viewControllers, stack)
        XCTAssertFalse(fixture.controller.view.isHidden)
        host.present()
        await fixture.waitForPresentation()
        XCTAssertTrue(host.isPresenting)
        XCTAssertFalse(fixture.controller.presentedViewController === presented)
    }

    func testDoesNotPresentOverAnotherHostModal() throws {
        let host = TanyaAIHost { _ in true }
        let fixture = try HostWindowFixture(Text("Host").tanyaAIHost(host))
        defer { fixture.close() }
        let other = UIViewController()
        fixture.controller.present(other, animated: false)
        fixture.settle()
        host.present()
        XCTAssertFalse(host.isPresenting)
        XCTAssertTrue(fixture.controller.presentedViewController === other)
    }

    func testHostAndFeatureReleaseAfterDismissAndTeardown() async throws {
        weak var releasedHost: TanyaAIHost?
        weak var releasedFeature: UIViewController?
        do {
            let host = TanyaAIHost { _ in true }
            let fixture = try HostWindowFixture(Text("Host").tanyaAIHost(host))
            host.present()
            await fixture.waitForPresentation()
            XCTAssertTrue(host.isPresenting)
            releasedHost = host
            releasedFeature = fixture.controller.presentedViewController
            let dismissed = expectation(description: "Dismiss before releasing owners")
            host.dismiss { dismissed.fulfill() }
            await fulfillment(of: [dismissed], timeout: 2)
            fixture.close()
        }
        let released = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in releasedHost == nil && releasedFeature == nil }, object: nil
        )
        await fulfillment(of: [released], timeout: 2)
        XCTAssertNil(releasedHost)
        XCTAssertNil(releasedFeature)
    }
}
