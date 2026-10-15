import TanyaAIDomain
import XCTest

@testable import TanyaAIPresentation

@MainActor
final class TanyaAIInlineLinkBehaviorTests: XCTestCase {
    func testWebLinksRouteToHostWebviewWithoutSendingAnyMessage() {
        let repository = TanyaAIRepositoryStub()
        let model = TanyaAIChatViewModel(repository: repository)
        var actions: [Action] = []
        model.onOutput = { output in
            if case .performAction(let action) = output { actions.append(action) }
        }
        let targets = ["https://www.google.com", "http://example.com/path?a=1", "HTTPS://example.com/path"]
        for target in targets { model.performInlineLink(target, identifier: "web-link") }

        XCTAssertEqual(actions.map(\.destinationType), [.webview, .webview, .webview])
        XCTAssertEqual(actions.map(\.deeplink), targets)
        XCTAssertTrue(actions.allSatisfy { $0.identifier == "web-link" })
        XCTAssertTrue(repository.receivedTexts.isEmpty)
        XCTAssertTrue(model.messages.isEmpty)
    }

    func testAppLinkRoutesToHostDeeplinkAndPreservesEncodedParameters() {
        let repository = TanyaAIRepositoryStub()
        let model = TanyaAIChatViewModel(repository: repository)
        var received: Action?
        model.onOutput = { output in
            if case .performAction(let action) = output { received = action }
        }
        let target = "ocbcid://mobile?type=portfolio&message=Halo%20Lara"
        model.performInlineLink(target)

        XCTAssertEqual(received?.destinationType, .deeplink)
        XCTAssertEqual(received?.deeplink, target)
        XCTAssertEqual(received?.identifier, "inline-link")
        XCTAssertTrue(repository.receivedTexts.isEmpty)
    }

    func testRelativeOrEmptyTargetsDoNotTriggerNavigationOrSending() {
        let repository = TanyaAIRepositoryStub()
        let model = TanyaAIChatViewModel(repository: repository)
        var outputCount = 0
        model.onOutput = { _ in outputCount += 1 }
        for target in ["", "/portfolio", "www.google.com"] { model.performInlineLink(target) }

        XCTAssertEqual(outputCount, 0)
        XCTAssertTrue(repository.receivedTexts.isEmpty)
    }
}
