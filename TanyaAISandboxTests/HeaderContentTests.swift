//
//  HeaderContentTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI
import XCTest

@testable import TanyaAI

@MainActor
final class HeaderContentTests: XCTestCase {
    func testInjectedContentReleasesOnDismissWhileHostRemainsOwned() async throws {
        let host = TanyaAIHost { _ in true }
        let fixture = try HostWindowFixture(Text("Host").tanyaAIHost(host))
        defer { fixture.close() }
        weak var releasedOwner: NSObject?
        do {
            let owner = NSObject()
            releasedOwner = owner
            host.present(languageCode: "zh-Hans") { HeaderTestContent(owner: owner) }
            await fixture.waitForPresentation()
            XCTAssertTrue(host.isPresenting)
            XCTAssertNotNil(releasedOwner)
            let dismissed = expectation(description: "Injected content dismissed")
            host.dismiss { dismissed.fulfill() }
            await fulfillment(of: [dismissed], timeout: 2)
        }
        let released = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in releasedOwner == nil }, object: nil
        )
        await fulfillment(of: [released], timeout: 2)
        XCTAssertFalse(host.isPresenting)
        XCTAssertNil(releasedOwner)
    }
}

private struct HeaderTestContent: View {
    let owner: NSObject
    var body: some View { Text(owner.description) }
}
