import DesignKit
import Foundation
import TanyaAIDomain
import XCTest

@testable import TanyaAIPresentation

/// Shortcuts are the host's way in, not the bot's answer to anything, so they
/// behave differently from the prompts a reply offers.
@MainActor
final class TanyaAIShortcutBehaviorTests: XCTestCase {
    func testUsingAShortcutLeavesTheRestInPlace() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(
            repository: repository,
            shortcuts: shortcuts
        )
        repository.sendUnsolicited(.history([]))

        viewModel.sendShortcut(shortcuts[0])

        XCTAssertEqual(repository.receivedText, "Saya mau transfer")
        XCTAssertEqual(viewModel.shortcuts.count, 2)
    }

    /// A turn is already open, so tapping one would do nothing. A control that
    /// ignores a tap is worse than one that is not there.
    func testShortcutsRemainUsableWhileAReplyArrives() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(
            repository: repository,
            shortcuts: shortcuts
        )
        repository.sendUnsolicited(.history([]))
        XCTAssertTrue(viewModel.isShortcutRowVisible)

        viewModel.sendShortcut(shortcuts[0])

        repository.send(.typing(true))
        XCTAssertTrue(viewModel.isShortcutRowVisible)
    }

    func testNoShortcutsMeansNoStrip() {
        let repository = TanyaAIRepositoryStub()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        repository.sendUnsolicited(.history([]))

        XCTAssertFalse(viewModel.isShortcutRowVisible)
    }

    private var shortcuts: [Suggestion] {
        [
            Suggestion(
                identifier: "transfer",
                title: "Transfer",
                prompt: "Saya mau transfer"
            ),
            Suggestion(
                identifier: "spending",
                title: "Pengeluaran",
                prompt: "Tampilkan spending"
            )
        ]
    }
}
