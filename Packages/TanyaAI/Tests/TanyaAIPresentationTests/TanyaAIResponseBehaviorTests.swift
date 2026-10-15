import Foundation
import TanyaAIDomain
import XCTest

@testable import TanyaAIPresentation

@MainActor
final class TanyaAIResponseBehaviorTests: XCTestCase {
    func testSelectionSendsPromptAndRetainsReadonlyChoiceWithSurroundingText() throws {
        let repository = TanyaAIRepositoryStub()
        let model = makeModel(repository)
        model.selectResponseOption("response", "products", "first")

        XCTAssertEqual(repository.receivedTexts, ["Buy first product"])
        XCTAssertEqual(model.messages.last?.content, .text("Buy first product"))
        let current = try response(in: model)
        XCTAssertTrue(current.isReadOnly)
        XCTAssertEqual(current.blocks.first, .text("Before the options"))
        XCTAssertEqual(current.blocks.last, .text("After the options"))
        let selected = try XCTUnwrap(current.options(identifier: "products"))
        XCTAssertEqual(selected.selectedIdentifier, "first")
        XCTAssertTrue(selected.isReadOnly)
        XCTAssertEqual(selected.choices, choices)
    }

    func testDuplicateTapAndReplayDoNotResendOrReviveSelection() throws {
        let repository = TanyaAIRepositoryStub()
        let model = makeModel(repository)
        model.selectResponseOption("response", "products", "first")
        repository.sendUnsolicited(.content(messageIdentifier: "response", content: .response(payload)))
        model.selectResponseOption("response", "products", "second")

        XCTAssertEqual(repository.receivedTexts, ["Buy first product"])
        XCTAssertEqual(model.messages.filter { $0.role == .user }.count, 1)
        let options = try XCTUnwrap(response(in: model).options(identifier: "products"))
        XCTAssertEqual(options.selectedIdentifier, "first")
        XCTAssertTrue(options.isReadOnly)
    }

    func testNewMessageLocksOptionsWithoutHidingTheirHistory() throws {
        let repository = TanyaAIRepositoryStub()
        let model = makeModel(repository)
        repository.sendUnsolicited(.content(messageIdentifier: "another", content: .text("Another answer")))
        model.selectResponseOption("response", "products", "first")

        XCTAssertTrue(repository.receivedTexts.isEmpty)
        let current = try response(in: model)
        let options = try XCTUnwrap(current.options(identifier: "products"))
        XCTAssertTrue(current.isReadOnly)
        XCTAssertTrue(options.isReadOnly)
        XCTAssertNil(options.selectedIdentifier)
        XCTAssertEqual(options.choices, choices)
    }

    func testUnknownMessageGroupAndChoiceLeaveCurrentOptionsUnconsumed() throws {
        let repository = TanyaAIRepositoryStub()
        let model = makeModel(repository)
        model.selectResponseOption("missing", "products", "first")
        model.selectResponseOption("response", "missing", "first")
        model.selectResponseOption("response", "products", "missing")

        XCTAssertTrue(repository.receivedTexts.isEmpty)
        let current = try response(in: model)
        XCTAssertFalse(current.isReadOnly)
        XCTAssertEqual(current, payload)
    }

    func testUnavailableChannelDoesNotConsumeThenReadyChannelCanSelect() throws {
        let repository = TanyaAIRepositoryStub()
        repository.isAutomaticConnection = false
        let model = makeModel(repository)
        model.selectResponseOption("response", "products", "first")
        XCTAssertTrue(repository.receivedTexts.isEmpty)
        XCTAssertFalse(try response(in: model).isReadOnly)
        repository.send(.connectionChanged(.ready))
        model.selectResponseOption("response", "products", "first")
        XCTAssertEqual(repository.receivedTexts, ["Buy first product"])
    }

    func testBlankChoicePromptDoesNotConsumeOrAppendUserMessage() throws {
        let repository = TanyaAIRepositoryStub()
        let model = TanyaAIChatViewModel(repository: repository)
        let options = ResponseOptions(
            identifier: "products", choices: [.init(identifier: "first", title: "First", prompt: " \n ")]
        )
        let blank = ResponsePayload(blocks: [.options(options)])
        repository.send(.content(messageIdentifier: "response", content: .response(blank)))
        model.selectResponseOption("response", "products", "first")
        XCTAssertTrue(repository.receivedTexts.isEmpty)
        XCTAssertEqual(model.messages.count, 1)
        XCTAssertEqual(try response(in: model), blank)
    }

    func testChangedReplayKeepsOriginalChosenHistoryWhenChoiceWasRemoved() throws {
        let repository = TanyaAIRepositoryStub()
        let model = makeModel(repository)
        model.selectResponseOption("response", "products", "first")
        let changed = ResponsePayload(blocks: [
            .text("Updated explanation"),
            .options(ResponseOptions(identifier: "products", choices: [choices[1]]))
        ])
        repository.send(.content(messageIdentifier: "response", content: .response(changed)))

        let current = try response(in: model)
        XCTAssertEqual(current.blocks.first, .text("Updated explanation"))
        let options = try XCTUnwrap(current.options(identifier: "products"))
        XCTAssertEqual(options.selectedIdentifier, "first")
        XCTAssertEqual(options.choices, choices)
        XCTAssertTrue(options.isReadOnly)
        model.selectResponseOption("response", "products", "second")
        XCTAssertEqual(repository.receivedTexts.count, 1)
    }

    private var choices: [ResponseChoice] {
        [
            .init(identifier: "first", title: "First product", prompt: "Buy first product"),
            .init(identifier: "second", title: "Second product", prompt: "Buy second product")
        ]
    }

    private var payload: ResponsePayload {
        ResponsePayload(blocks: [
            .text("Before the options"),
            .options(ResponseOptions(identifier: "products", title: "Choose product", choices: choices)),
            .text("After the options")
        ])
    }

    private func makeModel(_ repository: TanyaAIRepositoryStub) -> TanyaAIChatViewModel {
        let model = TanyaAIChatViewModel(repository: repository)
        repository.send(.content(messageIdentifier: "response", content: .response(payload)))
        return model
    }

    private func response(in model: TanyaAIChatViewModel) throws -> ResponsePayload {
        guard case .response(let response) = model.messages.first?.content else {
            throw CocoaError(.coderReadCorrupt)
        }
        return response
    }
}
