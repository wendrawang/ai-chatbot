import Foundation
import TanyaAIContracts
import TanyaAIDomain
import TanyaAITestSupport
import UIKit
import XCTest

@testable import TanyaAI

@MainActor
final class TanyaAIHostFlowTests: XCTestCase {
    func testHostReceivesChatPresenterWithoutDismissalOrNavigation() throws {
        let navigation = UINavigationController()
        var received: TanyaAIHostFlowRequest?
        weak var presenter: UIViewController?
        let coordinator = makeCoordinator(
            navigation,
            onHostFlow: { request, controller, _ in
                received = request
                presenter = controller
            }
        )
        coordinator.start()
        let request = documentRequest()

        coordinator.handleForTesting(.requestHostFlow(request))

        let chatController = try XCTUnwrap(navigation.topViewController)
        XCTAssertEqual(received, request)
        XCTAssertTrue(presenter === chatController)
        XCTAssertEqual(navigation.viewControllers.count, 1)
        XCTAssertNil(navigation.presentedViewController)
    }

    func testMissingHandlerLeavesNavigationUntouched() {
        let navigation = UINavigationController()
        let coordinator = makeCoordinator(navigation)
        coordinator.start()

        coordinator.handleForTesting(.requestHostFlow(documentRequest()))

        XCTAssertEqual(navigation.viewControllers.count, 1)
        XCTAssertNil(navigation.presentedViewController)
    }

    func testHeldHostCompletionDoesNotRetainReleasedConversation() {
        var completion: ((Result<TanyaAIHostFlowResult, Error>) -> Void)?
        weak var releasedModel: AnyObject?
        autoreleasepool {
            let navigation = UINavigationController()
            let coordinator = makeCoordinator(navigation, onHostFlow: { _, _, callback in completion = callback })
            coordinator.start()
            releasedModel = coordinator.chatViewModelForTesting
            coordinator.handleForTesting(.requestHostFlow(documentRequest()))
            navigation.setViewControllers([], animated: false)
        }
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        XCTAssertNotNil(completion)
        XCTAssertNil(releasedModel)
        completion?(.success(TanyaAIHostFlowResult(status: .cancelled)))
    }

    func testDocumentAndAuthorizationRequestsCarryRoutingReferencesOnly() {
        let request = documentRequest()
        XCTAssertEqual(request.kind, .document)
        XCTAssertEqual(request.referenceIdentifier, "terms")
        let authorization = TanyaAIHostFlowRequest(
            kind: .authorization, referenceIdentifier: "confirmation", title: "Authorize"
        )
        XCTAssertNotEqual(request.identifier, authorization.identifier)
        XCTAssertNil(authorization.destination)
        XCTAssertEqual(TanyaAIHostFlowResult(status: .processing).status, .processing)
    }

    func testDocumentAcceptanceFromBackgroundReturnsToTheSameConversation() throws {
        let session = MockTanyaAIChatSession(reply: { _ in [] })
        var completion: ((Result<TanyaAIHostFlowResult, Error>) -> Void)?
        let coordinator = makeCoordinator(
            UINavigationController(), session: session, onHostFlow: { _, _, callback in completion = callback }
        )
        coordinator.start()
        seedDocuments(session)
        let model = try XCTUnwrap(coordinator.chatViewModelForTesting)
        model.openResponseDocument("documents-message", "confirmation", "terms")
        let callback = try XCTUnwrap(completion)
        let delivered = expectation(description: "Host result returned to main")

        DispatchQueue.global().async {
            callback(.success(TanyaAIHostFlowResult(status: .accepted)))
            DispatchQueue.main.async { delivered.fulfill() }
        }
        wait(for: [delivered], timeout: 1)

        XCTAssertTrue(coordinator.chatViewModelForTesting === model)
        XCTAssertEqual(try documents(in: coordinator).acceptedIdentifiers, ["terms"])
        callback(.success(TanyaAIHostFlowResult(status: .cancelled)))
        settle()
        XCTAssertEqual(try documents(in: coordinator).acceptedIdentifiers, ["terms"])
    }

    func testCancelledDocumentDoesNotCreateAcceptance() throws {
        let session = MockTanyaAIChatSession(reply: { _ in [] })
        var completion: ((Result<TanyaAIHostFlowResult, Error>) -> Void)?
        let coordinator = makeCoordinator(
            UINavigationController(), session: session, onHostFlow: { _, _, callback in completion = callback }
        )
        coordinator.start()
        seedDocuments(session)

        coordinator.chatViewModelForTesting?.openResponseDocument("documents-message", "confirmation", "terms")
        let callback = try XCTUnwrap(completion)
        callback(.success(TanyaAIHostFlowResult(status: .cancelled)))
        settle()

        XCTAssertTrue(try documents(in: coordinator).acceptedIdentifiers.isEmpty)
    }

    func testLateHostResultIsIgnoredAfterChangingConversation() throws {
        let session = MockTanyaAIChatSession(reply: { _ in [] })
        var completion: ((Result<TanyaAIHostFlowResult, Error>) -> Void)?
        let coordinator = makeCoordinator(
            UINavigationController(), session: session, makeNewSession: { MockTanyaAIChatSession(reply: { _ in [] }) },
            onHostFlow: { _, _, callback in completion = callback }
        )
        coordinator.start()
        seedDocuments(session)
        let previousModel = try XCTUnwrap(coordinator.chatViewModelForTesting)
        previousModel.openResponseDocument("documents-message", "confirmation", "terms")
        let callback = try XCTUnwrap(completion)

        coordinator.handleForTesting(.startNewSession)
        callback(.success(TanyaAIHostFlowResult(status: .accepted)))
        settle()

        XCTAssertFalse(coordinator.chatViewModelForTesting === previousModel)
        XCTAssertTrue(coordinator.chatViewModelForTesting?.messages.isEmpty == true)
        guard case .response(let payload) = try XCTUnwrap(previousModel.messages.first).content,
            case .documents(let documents) = try XCTUnwrap(payload.blocks.first)
        else { return XCTFail("Expected previous document response") }
        XCTAssertTrue(documents.acceptedIdentifiers.isEmpty)
    }

    private func makeCoordinator(
        _ navigation: UINavigationController,
        session: TanyaAIChatSession = MockTanyaAIChatSession.sandbox(),
        makeNewSession: (() -> TanyaAIChatSession)? = nil,
        onHostFlow: TanyaAIHostFlowHandler? = nil
    ) -> TanyaAICoordinator {
        let container = TanyaAIDependencyContainer(
            configuration: TanyaAIConfiguration(),
            dependencies: TanyaAIDependencies(chatSession: session, theme: .sandbox)
        )
        return TanyaAICoordinator(
            navigationController: navigation, dependencyContainer: container,
            containerController: UIViewController(), hostFlowHandler: onHostFlow, makeNewSession: makeNewSession
        )
    }

    private func documentRequest() -> TanyaAIHostFlowRequest {
        TanyaAIHostFlowRequest(
            kind: .document, referenceIdentifier: "terms", title: "Terms", destination: "host://terms"
        )
    }

    private func seedDocuments(_ session: MockTanyaAIChatSession) {
        let json = #"""
            {"messageIdentifier":"documents-message","response":{"blocks":[{"type":"documents","documents":{
            "identifier":"confirmation","continueTitle":"Continue",
            "documents":[{"identifier":"terms","title":"Terms"}]}}]}}
            """#
        session.onEvent?(.structuredPayload(name: "response", json: Data(json.utf8)))
        settle()
    }

    private func documents(in coordinator: TanyaAICoordinator) throws -> ResponseDocuments {
        let message = try XCTUnwrap(coordinator.chatViewModelForTesting?.messages.first)
        guard case .response(let payload) = message.content,
            case .documents(let documents) = try XCTUnwrap(payload.blocks.first)
        else {
            XCTFail("Expected document response")
            throw CocoaError(.coderReadCorrupt)
        }
        return documents
    }

    private func settle() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    }
}
