import Foundation
import TanyaAIDomain
import TanyaAITestSupport
import XCTest
@testable import TanyaAI

final class TanyaAIRouterTests: XCTestCase {
    func testHistoryOutputAppendsTypedNavigationRoute() {
        let router = makeRouter()

        router.handle(.openHistory)

        XCTAssertEqual(router.path, [.history])
    }

    func testCloseOutputUsesHostBoundary() {
        var closeCount = 0
        let router = makeRouter {
            closeCount += 1
        }

        router.handle(.close)

        XCTAssertEqual(closeCount, 1)
    }

    func testEveryConfirmationCreatesAuthorizationSheetLazily() {
        confirmationKinds.forEach { kind in
            let router = makeRouter()
            let approval = makeApproval(kind)

            router.handle(.requestApproval(approval))

            XCTAssertEqual(router.authorizationSheet?.id, approval.approvalIdentifier)
            XCTAssertEqual(router.authorizationSheet?.approval.kind, kind)
            router.authorizationSheetDidDismiss()
            XCTAssertNil(router.authorizationSheet)
        }
    }

    func testActionOutputReachesTheHostWithoutOpeningAnything() {
        var received: [TanyaAIAction] = []
        let router = makeRouter(onAction: { received.append($0) })
        let action = TanyaAIAction(
            identifier: "open-transfer",
            deeplink: "ocbcid://mobile?type=transfer&amount=1250000"
        )

        router.handle(.performAction(action))

        XCTAssertEqual(received, [action])
        XCTAssertNil(router.authorizationSheet)
        XCTAssertTrue(router.path.isEmpty)
    }

    func testApprovalHandoffSkipsTheAuthorizationSheet() {
        var received: [TanyaAIAction] = []
        let router = makeRouter(onAction: { received.append($0) })
        let handoff = TanyaAIAction(
            identifier: "handoff-transfer",
            deeplink: "ocbcid://mobile?type=transfer"
        )
        let approval = makeApproval(.transfer, handoff: handoff)

        router.chatViewModel.approve(approval)

        XCTAssertEqual(received, [handoff])
        XCTAssertNil(router.authorizationSheet)
    }

    func testApprovalWithoutHandoffStillOpensTheAuthorizationSheet() {
        var received: [TanyaAIAction] = []
        let router = makeRouter(onAction: { received.append($0) })
        let approval = makeApproval(.transfer)

        router.chatViewModel.approve(approval)

        XCTAssertTrue(received.isEmpty)
        XCTAssertEqual(
            router.authorizationSheet?.id,
            approval.approvalIdentifier
        )
    }

    func testStartIsIdempotentWithoutInitialPrompt() {
        let router = makeRouter()

        router.startIfNeeded()
        router.startIfNeeded()

        XCTAssertEqual(router.chatViewModel.messages.count, 1)
    }

    private func makeRouter(
        onClose: @escaping () -> Void = {},
        onAction: @escaping (TanyaAIAction) -> Void = { _ in }
    ) -> TanyaAIRouter {
        let dependencyContainer = TanyaAIDependencyContainer(
            configuration: TanyaAIConfiguration(),
            dependencies: makeDependencies()
        )
        return TanyaAIRouter(
            dependencyContainer: dependencyContainer,
            closeHandler: onClose,
            actionHandler: onAction
        )
    }

    private func makeDependencies() -> TanyaAIDependencies {
        TanyaAIDependencies(
            streamingTransport: MockTanyaAIStreamingTransport(),
            authorizationService: MockTanyaAIAuthorizationService(),
            theme: .sandbox
        )
    }

    private func makeApproval(
        _ kind: TanyaAIApprovalPayload.Kind,
        handoff: TanyaAIAction? = nil
    ) -> TanyaAIApprovalPayload {
        TanyaAIApprovalPayload(
            approvalIdentifier: "\(kind.rawValue)-approval",
            transactionIdentifier: "demo-transaction",
            challengeIdentifier: "demo-challenge",
            kind: kind,
            title: "Confirm demo",
            summary: [],
            expiresAt: Date().addingTimeInterval(300),
            handoff: handoff,
            state: .awaitingApproval
        )
    }

    private var confirmationKinds: [TanyaAIApprovalPayload.Kind] {
        [.currencyConversion, .timeDeposit, .transfer, .savingsPlan]
    }
}
