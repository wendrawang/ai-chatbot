import Foundation
import TanyaAIContracts
import UIKit
import XCTest

@testable import TanyaAI

@MainActor
final class TanyaAINewSessionTests: XCTestCase {
    func testNewSessionReplacesConversationAndDisconnectsPreviousModel() throws {
        let previous = NavigationSessionSpy()
        let replacement = NavigationSessionSpy()
        let navigation = UINavigationController()
        let coordinator = makeCoordinator(navigation, session: previous, makeNewSession: { replacement })
        coordinator.start()
        settle()
        XCTAssertTrue(try XCTUnwrap(coordinator.chatViewModelForTesting).sendMessage("Old conversation"))
        weak var previousModel: AnyObject?
        previousModel = coordinator.chatViewModelForTesting
        let previousController = ObjectIdentifier(try XCTUnwrap(navigation.topViewController))

        autoreleasepool { coordinator.handleForTesting(.startNewSession) }
        settle()

        XCTAssertNil(previousModel)
        XCTAssertGreaterThan(previous.disconnectCount, 0)
        XCTAssertNil(previous.onEvent)
        XCTAssertEqual(replacement.connectCount, 1)
        XCTAssertTrue(try XCTUnwrap(coordinator.chatViewModelForTesting).messages.isEmpty)
        XCTAssertNotEqual(previousController, ObjectIdentifier(try XCTUnwrap(navigation.topViewController)))
        XCTAssertEqual(navigation.viewControllers.count, 1)
    }

    func testAbsentFactoryKeepsCurrentConversation() throws {
        let navigation = UINavigationController()
        let coordinator = makeCoordinator(navigation, session: NavigationSessionSpy())
        coordinator.start()
        let original = try XCTUnwrap(coordinator.chatViewModelForTesting)

        coordinator.handleForTesting(.startNewSession)

        XCTAssertTrue(coordinator.chatViewModelForTesting === original)
    }

    func testFactoryCannotReuseTheActiveAdapter() throws {
        let session = NavigationSessionSpy()
        let navigation = UINavigationController()
        let coordinator = makeCoordinator(navigation, session: session, makeNewSession: { session })
        coordinator.start()
        let original = try XCTUnwrap(coordinator.chatViewModelForTesting)

        coordinator.handleForTesting(.startNewSession)

        XCTAssertTrue(coordinator.chatViewModelForTesting === original)
        XCTAssertEqual(session.connectCount, 1)
        XCTAssertEqual(session.disconnectCount, 0)
    }

    func testNewSessionDoesNotRepeatAutomaticInitialPrompt() {
        let previous = NavigationSessionSpy()
        let replacement = NavigationSessionSpy()
        let coordinator = makeCoordinator(
            UINavigationController(), session: previous,
            configuration: TanyaAIConfiguration(initialPrompt: "Initial inquiry"), makeNewSession: { replacement }
        )
        coordinator.start()
        settle()
        XCTAssertEqual(previous.sentTexts, ["Initial inquiry"])

        coordinator.handleForTesting(.startNewSession)
        settle()

        XCTAssertTrue(replacement.sentTexts.isEmpty)
        XCTAssertTrue(coordinator.chatViewModelForTesting?.messages.isEmpty == true)
    }

    private func makeCoordinator(
        _ navigation: UINavigationController,
        session: TanyaAIChatSession,
        configuration: TanyaAIConfiguration = TanyaAIConfiguration(),
        makeNewSession: (() -> TanyaAIChatSession)? = nil
    ) -> TanyaAICoordinator {
        let container = TanyaAIDependencyContainer(
            configuration: configuration,
            dependencies: TanyaAIDependencies(chatSession: session, theme: .sandbox)
        )
        return TanyaAICoordinator(
            navigationController: navigation, dependencyContainer: container,
            containerController: UIViewController(), makeNewSession: makeNewSession
        )
    }

    private func settle() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    }
}

private final class NavigationSessionSpy: TanyaAIChatSession {
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?
    private(set) var connectCount = 0
    private(set) var disconnectCount = 0
    private(set) var sentTexts: [String] = []

    func connect() {
        connectCount += 1
        onEvent?(.connected)
    }

    func send(text: String, context: TanyaAIContext?, requestIdentifier: String) -> String? {
        sentTexts.append(text)
        onEvent?(.sendSucceeded(requestIdentifier: requestIdentifier, messageIdentifier: requestIdentifier))
        return requestIdentifier
    }

    func disconnect() { disconnectCount += 1 }
}
