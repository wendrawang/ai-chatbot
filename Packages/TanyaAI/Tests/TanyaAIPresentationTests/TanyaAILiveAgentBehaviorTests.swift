import DesignKit
import Foundation
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

/// Handing the conversation to a person is a question, not a link, so the
/// answer includes saying no - and the two answers behave differently.
final class TanyaAILiveAgentBehaviorTests: XCTestCase {
    func testDecliningSettlesTheCardAndSendsNothing() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        viewModel.declineLiveAgent(payload)

        XCTAssertNil(useCase.receivedText)
        XCTAssertTrue(isDeclined(in: viewModel))
    }

    /// Accepting is the same hand-off any deeplink takes: it reports an
    /// action and nothing else.
    func testAcceptingReportsTheDeeplink() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)
        var performed: Action?
        viewModel.onOutput = { output in
            if case .performAction(let action) = output {
                performed = action
            }
        }

        viewModel.perform(payload.action)

        XCTAssertEqual(performed?.identifier, "open-agent")
        XCTAssertNil(useCase.receivedText)
    }

    /// A customer who comes back from the agent screen may want to connect
    /// again, and the hand-off costs nothing to repeat.
    func testAcceptingLeavesTheOfferOpen() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        viewModel.perform(payload.action)

        XCTAssertFalse(isDeclined(in: viewModel))
    }

    func testDecliningTwiceChangesNothing() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        viewModel.declineLiveAgent(payload)
        viewModel.declineLiveAgent(payload)

        XCTAssertTrue(isDeclined(in: viewModel))
    }

    private var payload: LiveAgentPayload {
        LiveAgentPayload(
            identifier: "agent-1",
            title: "Anda akan diarahkan ke agen kami",
            detail: "Agen A siap membantu.",
            continueTitle: "Lanjut",
            cancelTitle: "Batal",
            action: Action(
                identifier: "open-agent",
                deeplink: "ocbcid://mobile?type=live-agent"
            )
        )
    }

    private func makeViewModel(
        useCase: TanyaAIChatUseCaseStub
    ) -> TanyaAIChatViewModel {
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        useCase.sendUnsolicited(
            .content(
                messageIdentifier: "agent-1",
                content: .liveAgent(payload)
            )
        )
        return viewModel
    }

    private func isDeclined(in viewModel: TanyaAIChatViewModel) -> Bool {
        for message in viewModel.messages {
            if case .liveAgent(let payload) = message.content {
                return payload.isDeclined
            }
        }
        return false
    }
}
