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

    func testStartIsIdempotentWithoutInitialPrompt() {
        let router = makeRouter()

        router.startIfNeeded()
        router.startIfNeeded()

        XCTAssertEqual(router.chatViewModel.messages.count, 1)
    }

    private func makeRouter(
        onClose: @escaping () -> Void = {}
    ) -> TanyaAIRouter {
        let dependencyContainer = TanyaAIDependencyContainer(
            configuration: TanyaAIConfiguration(),
            dependencies: makeDependencies()
        )
        return TanyaAIRouter(
            dependencyContainer: dependencyContainer,
            closeHandler: onClose
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
        _ kind: TanyaAIApprovalPayload.Kind
    ) -> TanyaAIApprovalPayload {
        TanyaAIApprovalPayload(
            approvalIdentifier: "\(kind.rawValue)-approval",
            transactionIdentifier: "demo-transaction",
            challengeIdentifier: "demo-challenge",
            kind: kind,
            title: "Confirm demo",
            summary: [],
            expiresAt: Date().addingTimeInterval(300),
            state: .awaitingApproval
        )
    }

    private var confirmationKinds: [TanyaAIApprovalPayload.Kind] {
        [.currencyConversion, .timeDeposit, .transfer, .savingsPlan]
    }
}
