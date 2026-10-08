import DesignKit
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

final class ChatCopyTests: XCTestCase {
    func testDefaultHistoryIsEmpty() {
        XCTAssertTrue(TanyaAIHistoryViewModel().items.isEmpty)
    }

    func testHistoryDisplaysOnlyHostSuppliedSummaries() {
        let items = [ConversationSummary(identifier: "host-id", title: "From host", detail: "Detail")]
        XCTAssertEqual(TanyaAIHistoryViewModel(items: items).items, items)
    }

    func testFailureUsesSelectedLanguage() {
        let viewModel = TanyaAIChatViewModel(
            useCase: TanyaAIChatUseCaseStub(), copy: CopyCatalog(localeIdentifier: "id")
        )
        viewModel.handleCompletion(.failure(TestError.interrupted))
        XCTAssertEqual(viewModel.errorMessage, "Respons terputus. Silakan coba lagi.")
    }

    func testFailureUsesHostOverride() {
        let viewModel = TanyaAIChatViewModel(
            useCase: TanyaAIChatUseCaseStub(),
            copy: CopyCatalog(overrides: ["chat.interrupted": "Please retry from host"])
        )
        viewModel.handleCompletion(.failure(TestError.interrupted))
        XCTAssertEqual(viewModel.errorMessage, "Please retry from host")
    }

    func testPresentationResourcesAndPlaceholdersResolve() {
        let copy = CopyCatalog(localeIdentifier: "id")
        XCTAssertEqual(copy.chat("chat.submit"), "Kirim")
        XCTAssertEqual(copy.chat("chat.subtitle"), "")
        XCTAssertEqual(copy.chat("chat.invalidPIN", values: ["count": "6"]), "Masukkan PIN 6 digit.")
    }

    private enum TestError: Error { case interrupted }
}
