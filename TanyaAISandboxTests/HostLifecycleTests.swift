//
//  HostLifecycleTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 17/10/26.
//

import DesignKit
import SwiftUI
import UIKit
import XCTest

@testable import TanyaAI

@MainActor
final class HostLifecycleTests: XCTestCase {
    func testPresentReportsWhetherTheFeatureOpened() async throws {
        let host = TanyaAIHost { _ in true }
        XCTAssertFalse(host.present())
        let fixture = try HostWindowFixture(Text("Host").tanyaAIHost(host))
        defer { fixture.close() }
        XCTAssertTrue(host.present())
        await fixture.waitForPresentation()
        XCTAssertFalse(host.present())
    }

    func testEveryDismissRequestCompletesAfterTheFeatureIsGone() async throws {
        let host = TanyaAIHost { _ in true }
        let fixture = try HostWindowFixture(Text("Host").tanyaAIHost(host))
        defer { fixture.close() }
        host.present()
        await fixture.waitForPresentation()
        let backButton = expectation(description: "Back button dismissal")
        let deeplink = expectation(description: "Deeplink arriving mid-dismissal")
        host.dismiss {
            XCTAssertNil(fixture.controller.presentedViewController)
            backButton.fulfill()
        }
        host.dismiss {
            XCTAssertNil(fixture.controller.presentedViewController)
            deeplink.fulfill()
        }
        await fulfillment(of: [backButton, deeplink], timeout: 2, enforceOrder: true)
        XCTAssertFalse(host.isPresenting)
    }

    func testDeeplinkDuringACancelledSwipeStillClosesTheFeature() async throws {
        let host = TanyaAIHost { _ in true }
        let fixture = try HostWindowFixture(Text("Host").tanyaAIHost(host))
        defer { fixture.close() }
        host.present()
        await fixture.waitForPresentation()
        let feature = try XCTUnwrap(fixture.controller.presentedViewController)
        let interaction = try XCTUnwrap((feature.transitioningDelegate as? TanyaAIPushTransition)?.interaction)
        interaction.isInteracting = true
        host.dismiss()
        fixture.settle()
        XCTAssertEqual(feature.transitionCoordinator?.isInteractive, true)
        interaction.update(0.3)
        let routed = expectation(description: "Deeplink routes after the feature closes")
        host.dismiss {
            XCTAssertNil(fixture.controller.presentedViewController)
            routed.fulfill()
        }
        interaction.isInteracting = false
        interaction.cancel()
        fixture.settle()
        XCTAssertTrue(fixture.controller.presentedViewController === feature)
        await fulfillment(of: [routed], timeout: 3)
        XCTAssertFalse(host.isPresenting)
        XCTAssertFalse(fixture.controller.view.isHidden)
    }

    func testReplacingMainWithPreloginClosesTheFeature() async throws {
        let host = TanyaAIHost { _ in true }
        let session = RootSessionState()
        let fixture = try HostWindowFixture(RootSessionFixture(session: session, host: host))
        defer { fixture.close() }
        host.present()
        await fixture.waitForPresentation()
        XCTAssertTrue(host.isPresenting)
        session.isMain = false
        let closed = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in fixture.controller.presentedViewController == nil }, object: nil
        )
        await fulfillment(of: [closed], timeout: 2)
        XCTAssertFalse(host.isPresenting)
        XCTAssertFalse(fixture.controller.view.isHidden)
        XCTAssertFalse(host.present())
    }

    func testThemeAndLocaleFromTheRootReachTheFeature() async throws {
        let host = TanyaAIHost { _ in true }
        let fixture = try HostWindowFixture(
            Text("Host").tanyaAIHost(host).designColors(PremierColorConstants())
                .environment(\.locale, Locale(identifier: "id"))
        )
        defer { fixture.close() }
        let probe = EnvironmentProbe()
        host.present { EnvironmentReader(probe: probe) }
        await fixture.waitForPresentation()
        XCTAssertTrue(probe.colors is PremierColorConstants)
        XCTAssertEqual(probe.locale?.identifier, "id")
    }

    func testReplacingTheWindowRootClosesTheFeature() async throws {
        let host = TanyaAIHost { _ in true }
        let fixture = try HostWindowFixture(Text("Main").tanyaAIHost(host))
        defer { fixture.close() }
        host.present()
        await fixture.waitForPresentation()
        weak var feature = fixture.controller.presentedViewController
        fixture.replaceRoot(with: UIViewController())
        let closed = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in feature?.view.window == nil }, object: nil
        )
        await fulfillment(of: [closed], timeout: 2)
        XCTAssertFalse(host.isPresenting)
    }
}

private final class RootSessionState: ObservableObject {
    @Published
    var isMain = true
}

/// Root host dengan dua anak: main memiliki Tanya AI, prelogin tidak.
private struct RootSessionFixture: View {
    @ObservedObject
    var session: RootSessionState
    let host: TanyaAIHost

    var body: some View {
        if session.isMain {
            Text("Main").tanyaAIHost(host)
        } else {
            Text("Prelogin")
        }
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
