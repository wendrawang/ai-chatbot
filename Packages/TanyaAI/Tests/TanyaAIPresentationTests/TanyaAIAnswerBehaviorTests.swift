import DesignKit
import Foundation
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

@MainActor
final class TanyaAIAnswerBehaviorTests: XCTestCase {
    func testRadioSendsPromptAndKeepsTheOtherParts() {
        let repository = TanyaAIRepositoryStub()
        let model = makeModel(repository)
        model.selectAnswerOption("answer", "help")

        XCTAssertEqual(repository.receivedText, "Contact support")
        XCTAssertEqual(model.messages.last?.content, .text("Contact support"))
        guard case .answer(let current) = model.messages.first?.content else { return XCTFail("Missing answer") }
        XCTAssertTrue(current.isAnswered)
        XCTAssertEqual(current.text, answer.text)
        XCTAssertEqual(current.image, answer.image)
        XCTAssertEqual(current.actions, answer.actions)
    }

    func testDuplicateTapAndReplayCannotResendOrReviveOptions() {
        let repository = TanyaAIRepositoryStub()
        let model = makeModel(repository)
        model.selectAnswerOption("answer", "help")
        repository.complete(.success(()))
        repository.sendUnsolicited(.content(messageIdentifier: "answer", content: .answer(answer)))
        model.selectAnswerOption("answer", "help")

        XCTAssertEqual(model.messages.filter { $0.role == .user }.count, 1)
        guard case .answer(let current) = model.messages.first?.content else { return XCTFail("Missing answer") }
        XCTAssertTrue(current.isAnswered)
    }

    func testInvalidOptionDoesNotSendAndUnavailableChannelKeepsOptions() {
        let repository = TanyaAIRepositoryStub()
        let model = makeModel(repository)
        model.selectAnswerOption("answer", "missing")
        XCTAssertNil(repository.receivedText)
        repository.send(.connectionChanged(.failed))
        model.selectAnswerOption("answer", "help")
        XCTAssertNil(repository.receivedText)
        guard case .answer(let current) = model.messages.first?.content else { return XCTFail("Missing answer") }
        XCTAssertFalse(current.isAnswered)
    }

    func testOnlyLatestAnswerCanBeSelected() {
        let repository = TanyaAIRepositoryStub()
        let model = makeModel(repository)
        repository.sendUnsolicited(.content(messageIdentifier: "other", content: .answer(answer)))
        model.selectAnswerOption("answer", "help")
        XCTAssertNil(repository.receivedText)
        guard case .answer(let previous) = model.messages[0].content else { return XCTFail("Missing previous") }
        XCTAssertTrue(previous.isAnswered)
        XCTAssertEqual(model.messages[1].content, .answer(answer))
    }

    func testRestoredAnsweredRadioIgnoresTap() {
        let repository = TanyaAIRepositoryStub()
        let model = TanyaAIChatViewModel(repository: repository)
        var restored = answer
        restored.isAnswered = true
        repository.sendUnsolicited(.history([
            TanyaAIMessage(identifier: "answer", role: .assistant, content: .answer(restored))
        ]))
        model.selectAnswerOption("answer", "help")
        XCTAssertNil(repository.receivedText)
    }

    func testTextDeltaKeepsOptionsImageAndActions() {
        let repository = TanyaAIRepositoryStub()
        let model = makeModel(repository)
        repository.sendUnsolicited(.textDelta(messageIdentifier: "answer", text: " Extra text"))
        repository.sendUnsolicited(.responseCompleted(messageIdentifier: "answer"))
        guard case .answer(let current) = model.messages.first?.content else { return XCTFail("Missing answer") }
        XCTAssertEqual(current.text, (answer.text ?? "") + " Extra text")
        XCTAssertEqual(current.options, answer.options)
        XCTAssertEqual(current.image, answer.image)
        XCTAssertEqual(current.actions, answer.actions)
    }

    func testLegacySingleChoicesSendImmediatelyAndStayConsumed() {
        let repository = TanyaAIRepositoryStub()
        let model = makeModel(repository)
        let choices = ChoicesPayload(identifier: "radio", title: "Question", choices: [
            .init(identifier: "help", title: "Help", prompt: "Contact support")
        ])
        repository.sendUnsolicited(.content(messageIdentifier: "radio", content: .choices(choices)))
        model.toggleChoice(choices, "help")
        repository.complete(.success(()))
        repository.sendUnsolicited(.content(messageIdentifier: "radio", content: .choices(choices)))
        model.toggleChoice(choices, "help")
        XCTAssertEqual(repository.receivedText, "Contact support")
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

    private func makeModel(_ repository: TanyaAIRepositoryStub) -> TanyaAIChatViewModel {
        let model = TanyaAIChatViewModel(repository: repository)
        repository.sendUnsolicited(.history([]))
        repository.sendUnsolicited(.content(messageIdentifier: "answer", content: .answer(answer)))
        return model
    }
}
