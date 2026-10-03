import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

final class TanyaAILatestOptionsTests: XCTestCase {
    func testRestoredOldRadioDisappearsButLatestRadioRemains() {
        let useCase = TanyaAIChatUseCaseStub()
        let model = TanyaAIChatViewModel(useCase: useCase)
        useCase.sendUnsolicited(.history([message("old"), message("latest")]))
        XCTAssertTrue(isAnswered(model.messages[0]))
        XCTAssertFalse(isAnswered(model.messages[1]))
    }

    func testNewTextHidesRadioAndLateReplayCannotReopenIt() {
        let useCase = TanyaAIChatUseCaseStub()
        let model = TanyaAIChatViewModel(useCase: useCase)
        useCase.sendUnsolicited(.history([message("old")]))
        useCase.sendUnsolicited(.content(messageIdentifier: "next", content: .text("Next answer")))
        useCase.sendUnsolicited(.content(messageIdentifier: "old", content: message("old").content))
        XCTAssertTrue(isAnswered(model.messages[0]))
        model.selectAnswerOption("old", "promo")
        XCTAssertNil(useCase.receivedText)
    }

    func testConfirmationRequiresHostHandlerAndOnlyTapRequestsPIN() throws {
        let payload = try JSONDecoder().decode(ConfirmationPayload.self, from: Data(
            #"{"confirmation_id":"conf","fields":[{"key":"amount","label":"Amount","value":"100"}]}"#.utf8
        ))
        let useCase = TanyaAIChatUseCaseStub()
        let model = TanyaAIChatViewModel(useCase: useCase, isConfirmationEnabled: true)
        var received: ConfirmationPayload?
        model.onOutput = { if case .requestConfirmation(let card) = $0 { received = card } }
        useCase.sendUnsolicited(.content(messageIdentifier: "card", content: .confirmation(payload)))
        XCTAssertNil(received)
        model.confirm(payload)
        XCTAssertEqual(received, payload)
        let unavailable = TanyaAIChatViewModel(useCase: TanyaAIChatUseCaseStub())
        unavailable.confirm(payload)
        XCTAssertNotNil(unavailable.errorMessage)
    }

    private func message(_ identifier: String) -> TanyaAIMessage {
        TanyaAIMessage(identifier: identifier, role: .assistant, content: .answer(AnswerPayload(
            text: "Choose", options: [.init(identifier: "promo", title: "Promotion", prompt: "Promotion")]
        )))
    }

    private func isAnswered(_ message: TanyaAIMessageItemViewModel) -> Bool {
        guard case .answer(let answer) = message.content else { return false }
        return answer.isAnswered
    }
}
