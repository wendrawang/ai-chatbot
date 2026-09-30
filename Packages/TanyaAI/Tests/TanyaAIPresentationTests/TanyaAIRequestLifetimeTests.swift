import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIRequestLifetimeTests: XCTestCase {
    func testSynchronousCompletionDoesNotRetainTheFinishedRequest() {
        let useCase = RequestLifetimeStub()
        useCase.isSynchronous = true
        let viewModel = TanyaAIChatViewModel(useCase: useCase)

        viewModel.sendMessage("Hello")

        XCTAssertFalse(viewModel.isGenerating)
        XCTAssertNil(useCase.lastTask)
    }

    func testCancelledCallbacksCannotEndTheNextRequest() {
        let useCase = RequestLifetimeStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        viewModel.sendMessage("First")
        viewModel.cancelGeneration()
        viewModel.sendMessage("Second")

        useCase.eventHandlers[0](.textDelta(messageIdentifier: "stale", text: "Late"))
        useCase.completions[0](.success(()))

        XCTAssertTrue(viewModel.isGenerating)
        XCTAssertFalse(viewModel.messages.contains { $0.identifier == "stale" })
        useCase.completions[1](.success(()))
        XCTAssertFalse(viewModel.isGenerating)
        XCTAssertNil(useCase.lastTask)
    }

    func testSavedCallbacksDoNotKeepTheViewModelAlive() {
        let useCase = RequestLifetimeStub()
        weak var released: TanyaAIChatViewModel?
        autoreleasepool {
            let viewModel = TanyaAIChatViewModel(useCase: useCase)
            viewModel.sendMessage("Hello")
            released = viewModel
        }

        XCTAssertNil(released)
        XCTAssertNil(useCase.lastTask)
        useCase.completions[0](.success(()))
    }
}

private final class RequestLifetimeStub: TanyaAIChatUseCaseProtocol {
    var isSynchronous = false
    var completions: [(Result<Void, Error>) -> Void] = []
    var eventHandlers: [(TanyaAIStreamEvent) -> Void] = []
    weak var lastTask: TanyaAINoOpCancellable?

    func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        let task = TanyaAINoOpCancellable()
        lastTask = task
        eventHandlers.append(onEvent)
        completions.append(completion)
        if isSynchronous { completion(.success(())) }
        return task
    }
}
