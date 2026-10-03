import DesignKit
import Foundation
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIAnswerBehaviorTests: XCTestCase {
    func testRadioSendsPromptAndKeepsTheOtherParts() {
        let useCase = TanyaAIChatUseCaseStub()
        let model = makeModel(useCase)
        model.selectAnswerOption("answer", "help")

        XCTAssertEqual(useCase.receivedText, "Contact support")
        XCTAssertEqual(model.messages.last?.content, .text("Contact support"))
        guard case .answer(let current) = model.messages.first?.content else { return XCTFail("Missing answer") }
        XCTAssertTrue(current.isAnswered)
        XCTAssertEqual(current.text, answer.text)
        XCTAssertEqual(current.image, answer.image)
        XCTAssertEqual(current.actions, answer.actions)
    }

    func testDuplicateTapAndReplayCannotResendOrReviveOptions() {
        let useCase = TanyaAIChatUseCaseStub()
        let model = makeModel(useCase)
        model.selectAnswerOption("answer", "help")
        useCase.complete(.success(()))
        useCase.sendUnsolicited(.content(messageIdentifier: "answer", content: .answer(answer)))
        model.selectAnswerOption("answer", "help")

        XCTAssertEqual(model.messages.filter { $0.role == .user }.count, 1)
        guard case .answer(let current) = model.messages.first?.content else { return XCTFail("Missing answer") }
        XCTAssertTrue(current.isAnswered)
    }

    func testInvalidOptionAndBusyTapKeepTheDraftAndOptions() {
        let useCase = TanyaAIChatUseCaseStub()
        let model = makeModel(useCase)
        model.inputText = "My draft"
        model.selectAnswerOption("answer", "missing")
        XCTAssertEqual(model.inputText, "My draft")
        XCTAssertNil(useCase.receivedText)
        model.sendMessage("First request")
        model.inputText = "Next draft"
        model.selectAnswerOption("answer", "help")
        XCTAssertEqual(model.inputText, "Next draft")
        guard case .answer(let current) = model.messages.first?.content else { return XCTFail("Missing answer") }
        XCTAssertTrue(current.isAnswered)
    }

    func testOnlyLatestAnswerCanBeSelected() {
        let useCase = TanyaAIChatUseCaseStub()
        let model = makeModel(useCase)
        useCase.sendUnsolicited(.content(messageIdentifier: "other", content: .answer(answer)))
        model.selectAnswerOption("answer", "help")
        XCTAssertNil(useCase.receivedText)
        guard case .answer(let previous) = model.messages[0].content else { return XCTFail("Missing previous") }
        XCTAssertTrue(previous.isAnswered)
        XCTAssertEqual(model.messages[1].content, .answer(answer))
    }

    func testRestoredAnsweredRadioIgnoresTap() {
        let useCase = TanyaAIChatUseCaseStub()
        let model = TanyaAIChatViewModel(useCase: useCase)
        var restored = answer
        restored.isAnswered = true
        useCase.sendUnsolicited(.history([
            TanyaAIMessage(identifier: "answer", role: .assistant, content: .answer(restored))
        ]))
        model.selectAnswerOption("answer", "help")
        XCTAssertNil(useCase.receivedText)
    }

    func testTextDeltaKeepsOptionsImageAndActions() {
        let useCase = TanyaAIChatUseCaseStub()
        let model = makeModel(useCase)
        useCase.sendUnsolicited(.textDelta(messageIdentifier: "answer", text: " Extra text"))
        useCase.sendUnsolicited(.responseCompleted(messageIdentifier: "answer"))
        guard case .answer(let current) = model.messages.first?.content else { return XCTFail("Missing answer") }
        XCTAssertEqual(current.text, (answer.text ?? "") + " Extra text")
        XCTAssertEqual(current.options, answer.options)
        XCTAssertEqual(current.image, answer.image)
        XCTAssertEqual(current.actions, answer.actions)
    }

    func testLegacySingleChoicesSendImmediatelyAndStayConsumed() {
        let useCase = TanyaAIChatUseCaseStub()
        let model = makeModel(useCase)
        let choices = ChoicesPayload(identifier: "radio", title: "Question", choices: [
            .init(identifier: "help", title: "Help", prompt: "Contact support")
        ])
        useCase.sendUnsolicited(.content(messageIdentifier: "radio", content: .choices(choices)))
        model.toggleChoice(choices, "help")
        useCase.complete(.success(()))
        useCase.sendUnsolicited(.content(messageIdentifier: "radio", content: .choices(choices)))
        model.toggleChoice(choices, "help")
        XCTAssertEqual(useCase.receivedText, "Contact support")
        XCTAssertEqual(model.messages.filter { $0.role == .user }.count, 1)
        guard case .choices(let current) = model.messages[1].content else { return XCTFail("Missing question") }
        XCTAssertTrue(current.isSubmitted)
    }

    private var answer: AnswerPayload {
        AnswerPayload(
            text: "Choose a service",
            options: [.init(identifier: "help", title: "Help", prompt: "Contact support")],
            image: ImagePayload(imageURL: nil, caption: "Promotion"),
            actions: ActionPayload(buttons: [.init(
                title: "Open", action: .init(identifier: "open", deeplink: "host://open")
            )])
        )
    }

    private func makeModel(_ useCase: TanyaAIChatUseCaseStub) -> TanyaAIChatViewModel {
        let model = TanyaAIChatViewModel(useCase: useCase)
        useCase.sendUnsolicited(.history([]))
        useCase.sendUnsolicited(.content(messageIdentifier: "answer", content: .answer(answer)))
        return model
    }
}
