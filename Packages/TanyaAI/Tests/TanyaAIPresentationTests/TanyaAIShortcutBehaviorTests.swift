import DesignKit
import Foundation
import TanyaAIDomain
import XCTest
@testable import TanyaAIPresentation

/// Shortcuts are the host's way in, not the bot's answer to anything, so they
/// behave differently from the prompts a reply offers.
final class TanyaAIShortcutBehaviorTests: XCTestCase {
    func testUsingAShortcutLeavesTheRestInPlace() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(
            useCase: useCase,
            shortcuts: shortcuts
        )
        useCase.sendUnsolicited(.history([]))

        viewModel.sendShortcut(shortcuts[0])

        XCTAssertEqual(useCase.receivedText, "Saya mau transfer")
        XCTAssertEqual(viewModel.shortcuts.count, 2)
    }

    /// A turn is already open, so tapping one would do nothing. A control that
    /// ignores a tap is worse than one that is not there.
    func testShortcutsAreHiddenWhileAReplyArrives() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(
            useCase: useCase,
            shortcuts: shortcuts
        )
        useCase.sendUnsolicited(.history([]))
        XCTAssertTrue(viewModel.showsShortcuts)

        viewModel.sendShortcut(shortcuts[0])

        XCTAssertFalse(viewModel.showsShortcuts)
    }

    func testNoShortcutsMeansNoStrip() {
        let useCase = TanyaAIChatUseCaseStub()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        useCase.sendUnsolicited(.history([]))

        XCTAssertFalse(viewModel.showsShortcuts)
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
