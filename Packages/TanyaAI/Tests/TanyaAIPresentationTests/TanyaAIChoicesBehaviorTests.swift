import DesignKit
import Foundation
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

/// Picking chips changes nothing until submit. That is the whole reason this
/// bubble exists rather than reusing the prompts, so it is what these pin.
final class TanyaAIChoicesBehaviorTests: XCTestCase {
    func testTappingChipsSendsNothing() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        viewModel.toggleChoice(payload, "dining")
        viewModel.toggleChoice(payload, "hotel")

        XCTAssertNil(useCase.receivedText)
        XCTAssertEqual(selection(in: viewModel), ["dining", "hotel"])
    }

    func testSubmitSendsTheAnswerAndSettlesTheCard() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        viewModel.toggleChoice(payload, "dining")
        viewModel.submitChoices(payload)

        XCTAssertEqual(useCase.receivedText, "Promo dining")
        XCTAssertTrue(isSubmitted(in: viewModel))
    }

    /// The question stays on screen after it is answered - the conversation is
    /// the record of both halves - but it stops taking input.
    func testASettledCardIgnoresFurtherTaps() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        viewModel.toggleChoice(payload, "dining")
        viewModel.submitChoices(payload)
        viewModel.toggleChoice(payload, "hotel")

        XCTAssertEqual(selection(in: viewModel), ["dining"])
    }

    func testSubmitWithNothingPickedSendsNothing() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = makeViewModel(useCase: useCase)

        viewModel.submitChoices(payload)

        XCTAssertNil(useCase.receivedText)
        XCTAssertFalse(isSubmitted(in: viewModel))
    }

    private var payload: ChoicesPayload {
        ChoicesPayload(
            identifier: "q1",
            title: "Kategori apa yang diinginkan",
            choices: [
                .init(
                    identifier: "dining",
                    title: "Dining",
                    prompt: "Promo dining"
                ),
                .init(
                    identifier: "hotel",
                    title: "Hotel & Travel",
                    prompt: "Promo hotel"
                )
            ]
        )
    }

    private func makeViewModel(
        useCase: TanyaAIChatUseCaseStub
    ) -> TanyaAIChatViewModel {
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        useCase.sendUnsolicited(
            .content(messageIdentifier: "q1", content: .choices(payload))
        )
        return viewModel
    }

    private func card(
        in viewModel: TanyaAIChatViewModel
    ) -> ChoicesPayload? {
        for message in viewModel.messages {
            if case .choices(let payload) = message.content {
                return payload
            }
        }
        return nil
    }

    private func selection(
        in viewModel: TanyaAIChatViewModel
    ) -> Set<String> {
        card(in: viewModel)?.selected ?? []
    }

    private func isSubmitted(in viewModel: TanyaAIChatViewModel) -> Bool {
        card(in: viewModel)?.isSubmitted ?? false
    }
}
