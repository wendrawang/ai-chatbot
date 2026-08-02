import TanyaAIContracts
import XCTest
@testable import TanyaAIDomain

final class TanyaAIChatUseCaseTests: XCTestCase {
    func testUseCaseForwardsMessageToRepository() {
        let repository = TanyaAIRepositorySpy()
        let useCase = TanyaAIChatUseCase(repository: repository)

        _ = useCase.sendMessage(
            conversationIdentifier: "conversation-demo",
            text: "Hello",
            onEvent: { _ in },
            completion: { _ in }
        )

        XCTAssertEqual(repository.receivedConversationIdentifier, "conversation-demo")
        XCTAssertEqual(repository.receivedText, "Hello")
    }
}

private final class TanyaAIRepositorySpy: TanyaAIRepository {
    var receivedConversationIdentifier: String?
    var receivedText: String?

    func sendMessage(
        conversationIdentifier: String?,
        text: String,
        onEvent: @escaping (TanyaAIStreamEvent) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        receivedConversationIdentifier = conversationIdentifier
        receivedText = text
        return TanyaAINoOpCancellable()
    }
}
