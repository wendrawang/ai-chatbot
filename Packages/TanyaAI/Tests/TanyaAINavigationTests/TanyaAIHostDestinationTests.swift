import Foundation
import TanyaAITestSupport
import XCTest
@testable import TanyaAI

final class TanyaAIHostDestinationTests: XCTestCase {
    func testLegacyDeeplinkRemainsRestrictedToConfiguredSchemeAndHost() {
        let host = makeHost()
        XCTAssertNotNil(host.accepted(action("ocbcid://mobile?type=transfer", .deeplink)))
        XCTAssertNil(host.accepted(action("ocbcid://other?type=transfer", .deeplink)))
        XCTAssertNil(host.accepted(action("https://example.com", .deeplink)))
        XCTAssertNil(host.accepted(action("tel:123", .deeplink)))
    }

    func testExternalDestinationsRequireOptInAndHTTPSWithoutCredentials() {
        XCTAssertNil(makeHost().accepted(action("https://example.com", .browser)))
        let host = makeHost(isRoutingEnabled: true)
        for type in [TanyaAIAction.DestinationType.webview, .browser] {
            XCTAssertNotNil(host.accepted(action("https://example.com/path?q=hello", type)))
            XCTAssertNil(host.accepted(action("http://example.com", type)))
            XCTAssertNil(host.accepted(action("https://user:secret@example.com", type)))
            XCTAssertNil(host.accepted(action("file:///tmp/data", type)))
            XCTAssertNil(host.accepted(action("javascript:alert(1)", type)))
        }
    }

    private func action(_ target: String, _ type: TanyaAIAction.DestinationType) -> TanyaAIAction {
        .init(identifier: "link", deeplink: target, destinationType: type)
    }

    private func makeHost(isRoutingEnabled: Bool = false) -> TanyaAIHost {
        TanyaAIHost(
            theme: .sandbox, deeplinkScheme: "ocbcid", deeplinkHost: "mobile",
            makeSession: { MockTanyaAIChatSession.sandbox() },
            onDestination: isRoutingEnabled ? { _, _ in } : nil,
            onDeeplink: { _ in }
        )
    }
}
