import TanyaAIDesignSystem
import TanyaAIDomain
import UIKit
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIMessageListTests: XCTestCase {
    /// The restored conversation has to reach the screen already at its
    /// latest message. Parking on the next runloop would draw one frame at
    /// the top of the conversation first, which is the jump customers saw.
    func testRestoredConversationIsParkedBeforeItIsDrawn() {
        let coordinator = TanyaAIMessageTableView.Coordinator()
        let tableView = makeTableView(coordinator: coordinator)

        coordinator.update(
            restoring,
            theme: .sandbox,
            handlers: .inert
        )
        coordinator.update(
            restored(messageCount: 20),
            theme: .sandbox,
            handlers: .inert
        )

        XCTAssertGreaterThan(tableView.contentOffset.y, 0)
        XCTAssertEqual(
            tableView.contentOffset.y,
            bottomOffset(of: tableView),
            accuracy: 1
        )
    }

    /// Nothing to park against. The empty case must not scroll into a void.
    func testRestoringToAnEmptyConversationStaysAtTheTop() {
        let coordinator = TanyaAIMessageTableView.Coordinator()
        let tableView = makeTableView(coordinator: coordinator)

        coordinator.update(restoring, theme: .sandbox, handlers: .inert)
        coordinator.update(
            restored(messageCount: 0),
            theme: .sandbox,
            handlers: .inert
        )

        XCTAssertEqual(tableView.contentOffset.y, 0, accuracy: 1)
    }

    func testTypingRowCountsAsARow() {
        let state = TanyaAIMessageListState(
            messages: [],
            isRestoring: false,
            showsTypingRow: true,
            showsSuggestions: false
        )

        XCTAssertEqual(state.rowCount, 1)
        XCTAssertEqual(restored(messageCount: 3).rowCount, 3)
    }

    /// A message editing its own contents is not a row change: the row
    /// observes that itself, and reloading would drop its animation.
    func testRowsDifferOnlyWhenTheRowsThemselvesChange() {
        let first = restored(messageCount: 2)
        let same = TanyaAIMessageListState(
            messages: first.messages,
            isRestoring: false,
            showsTypingRow: false,
            showsSuggestions: true
        )

        XCTAssertFalse(same.rowsDiffer(from: first))
        XCTAssertTrue(restored(messageCount: 3).rowsDiffer(from: first))
        XCTAssertTrue(restoring.rowsDiffer(from: first))
    }

    private var restoring: TanyaAIMessageListState {
        TanyaAIMessageListState(
            messages: [],
            isRestoring: true,
            showsTypingRow: false,
            showsSuggestions: false
        )
    }

    private func restored(messageCount: Int) -> TanyaAIMessageListState {
        let messages = (0..<messageCount).map { index in
            TanyaAIMessageItemViewModel(
                message: TanyaAIMessage(
                    identifier: "message-\(index)",
                    role: index.isMultiple(of: 2) ? .user : .assistant,
                    content: .text("Message \(index)")
                )
            )
        }
        return TanyaAIMessageListState(
            messages: messages,
            isRestoring: false,
            showsTypingRow: false,
            showsSuggestions: false
        )
    }

    private func makeTableView(
        coordinator: TanyaAIMessageTableView.Coordinator
    ) -> UITableView {
        let tableView = TanyaAITrackingTableView(
            frame: CGRect(x: 0, y: 0, width: 320, height: 480),
            style: .plain
        )
        tableView.dataSource = coordinator
        tableView.delegate = coordinator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.register(
            TanyaAIHostingTableViewCell.self,
            forCellReuseIdentifier: TanyaAIHostingTableViewCell.reuseIdentifier
        )
        coordinator.attach(tableView)
        return tableView
    }

    private func bottomOffset(of tableView: UITableView) -> CGFloat {
        max(
            -tableView.adjustedContentInset.top,
            tableView.contentSize.height
                - tableView.bounds.height
                + tableView.adjustedContentInset.bottom
        )
    }
}
