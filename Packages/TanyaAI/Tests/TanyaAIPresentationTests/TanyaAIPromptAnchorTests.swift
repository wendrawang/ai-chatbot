import DesignKit
import TanyaAIDomain
import UIKit
import XCTest

@testable import TanyaAIPresentation

@MainActor
final class TanyaAIPromptAnchorTests: XCTestCase {
    func testNewPromptLeavesPreviousAnswerPreviewEvenWithShortReply() {
        let mounted = mount()
        defer { mounted.window.isHidden = true }
        let messages = conversation()
        mounted.coordinator.update(state(messages), theme: .sandbox, handlers: .inert)
        mounted.coordinator.update(state(messages, prompt: "prompt"), theme: .sandbox, handlers: .inert)

        assertPromptPosition(mounted.table)
        XCTAssertGreaterThan(mounted.coordinator.promptTrailingInset, 0)
        XCTAssertFalse(mounted.coordinator.isFollowingLatestMessage)
        let previous = mounted.table.rectForRow(at: IndexPath(row: 1, section: 0))
        XCTAssertGreaterThan(previous.maxY - mounted.table.contentOffset.y, 0)
        XCTAssertEqual(mounted.table.numberOfRows(inSection: 0), messages.count)
    }

    func testGrowingAnswerHoldsPromptAndReleasesUnneededTrailingSpace() {
        let mounted = mount()
        defer { mounted.window.isHidden = true }
        let control = TanyaAIMessageScrollControl()
        mounted.coordinator.updateScrollControl(control)
        let messages = conversation()
        mounted.coordinator.update(state(messages, prompt: "prompt"), theme: .sandbox, handlers: .inert)

        messages[3].update(content: .text(String(repeating: "A growing reply with several words. ", count: 70)))
        settle()

        assertPromptPosition(mounted.table)
        XCTAssertEqual(mounted.coordinator.promptTrailingInset, 0, accuracy: 1)
        XCTAssertTrue(control.isAwayFromLatest)
    }

    func testManualReadingCancelsAnchorAndNewRepliesDoNotMoveIt() {
        let mounted = mount()
        defer { mounted.window.isHidden = true }
        let messages = conversation()
        mounted.coordinator.update(state(messages, prompt: "prompt"), theme: .sandbox, handlers: .inert)
        settle()
        mounted.coordinator.scrollViewWillBeginDragging(mounted.table)
        mounted.table.setContentOffset(CGPoint(x: 0, y: 10), animated: false)
        settle()
        let before = mounted.table.contentOffset.y

        messages[3].update(content: .text(String(repeating: "An answer that arrives while reading. ", count: 30)))
        settle()

        XCTAssertNil(mounted.coordinator.activePromptIdentifier)
        XCTAssertFalse(mounted.coordinator.isFollowingLatestMessage)
        XCTAssertEqual(mounted.table.contentOffset.y, before, accuracy: 1)
    }

    func testLatestButtonClearsAnchorSlackAndReachesActualBottom() {
        let mounted = mount()
        defer { mounted.window.isHidden = true }
        let control = TanyaAIMessageScrollControl()
        mounted.coordinator.updateScrollControl(control)
        mounted.coordinator.update(state(conversation(), prompt: "prompt"), theme: .sandbox, handlers: .inert)
        XCTAssertGreaterThan(mounted.coordinator.promptTrailingInset, 0)

        control.returnToLatest()
        mounted.coordinator.updateScrollControl(control)
        settle()

        XCTAssertNil(mounted.coordinator.activePromptIdentifier)
        XCTAssertEqual(mounted.coordinator.promptTrailingInset, 0)
        XCTAssertTrue(mounted.coordinator.isFollowingLatestMessage)
        XCTAssertFalse(control.isAwayFromLatest)
        let bottom = max(
            -mounted.table.adjustedContentInset.top,
            mounted.table.contentSize.height - mounted.table.bounds.height + mounted.table.adjustedContentInset.bottom
        )
        XCTAssertEqual(mounted.table.contentOffset.y, bottom, accuracy: 1)
    }

    func testTimestampOffsetsAnchorRowWithoutChangingMessageOrder() {
        var snapshot = state(conversation(), prompt: "prompt")
        snapshot.timestamp = "14 Okt 2026, 10:00"
        XCTAssertEqual(snapshot.rowIndex(messageIdentifier: "prompt"), 3)
        guard case .message(let item) = snapshot.kind(at: 3) else { return XCTFail("Expected prompt row") }
        XCTAssertEqual(item.identifier, "prompt")
        XCTAssertNil(snapshot.rowIndex(messageIdentifier: "missing"))
    }

    private func assertPromptPosition(_ table: UITableView, file: StaticString = #filePath, line: UInt = #line) {
        let prompt = table.rectForRow(at: IndexPath(row: 2, section: 0))
        XCTAssertEqual(
            prompt.minY - table.contentOffset.y,
            table.adjustedContentInset.top + ChatLayoutMetrics.previousAnswerPreview.scaledToArtwork,
            accuracy: 1, file: file, line: line
        )
    }

    private func conversation() -> [TanyaAIMessageItemViewModel] {
        [
            item("earlier", role: .user, text: "Earlier question"),
            item(
                "previous", role: .assistant,
                text: String(repeating: "The previous answer remains in history. ", count: 12)),
            item("prompt", role: .user, text: "New question"),
            item("reply", role: .assistant, text: "Short reply")
        ]
    }

    private func item(_ identifier: String, role: TanyaAIMessage.Role, text: String) -> TanyaAIMessageItemViewModel {
        TanyaAIMessageItemViewModel(
            message: TanyaAIMessage(identifier: identifier, role: role, content: .text(text))
        )
    }

    private func state(
        _ messages: [TanyaAIMessageItemViewModel], prompt: String? = nil
    ) -> TanyaAIMessageListState {
        TanyaAIMessageListState(
            messages: messages, isRestoring: false, isTypingRowVisible: false, latestPromptIdentifier: prompt
        )
    }

    private func settle() {
        let settled = expectation(description: "Hosted rows and coalesced scroll settle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { settled.fulfill() }
        wait(for: [settled], timeout: 2)
    }

    private func mount() -> MountedTable {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 700))
        let controller = UIViewController()
        let table = LayoutTrackingTableView(frame: window.bounds)
        let coordinator = MessageTableView.Coordinator()
        table.register(MessageHostingCell.self, forCellReuseIdentifier: MessageHostingCell.reuseIdentifier)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 60
        table.dataSource = coordinator
        table.delegate = coordinator
        coordinator.attach(table, parent: controller)
        window.rootViewController = controller
        controller.view.addSubview(table)
        window.makeKeyAndVisible()
        return MountedTable(window: window, table: table, coordinator: coordinator)
    }
}

private struct MountedTable {
    let window: UIWindow
    let table: LayoutTrackingTableView
    let coordinator: MessageTableView.Coordinator
}
