import DesignKit
import TanyaAIDomain
import XCTest

@testable import TanyaAIPresentation

@MainActor
final class ChatCopyTests: XCTestCase {
    func testFailureUsesSelectedLanguage() {
        let viewModel = TanyaAIChatViewModel(
            repository: TanyaAIRepositoryStub(), copy: CopyCatalog(localeIdentifier: "id")
        )
        viewModel.handle(.connectionChanged(.failed))
        XCTAssertEqual(viewModel.errorMessage, "Chat belum tersedia. Silakan coba lagi.")
    }

    func testFailureUsesHostOverride() {
        let viewModel = TanyaAIChatViewModel(
            repository: TanyaAIRepositoryStub(),
            copy: CopyCatalog(overrides: ["chat.connectionFailed": "Please retry from host"])
        )
        viewModel.handle(.connectionChanged(.failed))
        XCTAssertEqual(viewModel.errorMessage, "Please retry from host")
    }

    func testCurrentPresentationResourcesResolve() {
        let copy = CopyCatalog(localeIdentifier: "id")
        XCTAssertEqual(copy.chat("chat.send"), "Kirim pesan")
        XCTAssertEqual(copy.chat("chat.subtitle"), "")
        XCTAssertEqual(copy.chat("chat.newSession"), "Percakapan baru")
    }

}
