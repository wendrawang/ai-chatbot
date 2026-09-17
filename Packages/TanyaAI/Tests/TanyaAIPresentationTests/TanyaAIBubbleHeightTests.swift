import TanyaAIDomain
import UIKit
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIBubbleHeightTests: XCTestCase {
    func testGrowingTextResizesRowAndMovesFollowingBubble() {
        let coordinator = TanyaAIMessageTableView.Coordinator()
        let tableView = TanyaAITrackingTableView(frame: CGRect(x: 0, y: 0, width: 390, height: 700))
        tableView.register(
            TanyaAIHostingTableViewCell.self,
            forCellReuseIdentifier: TanyaAIHostingTableViewCell.reuseIdentifier
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.dataSource = coordinator
        tableView.delegate = coordinator
        coordinator.attach(tableView)
        let window = UIWindow(frame: tableView.frame)
        let controller = UIViewController()
        window.rootViewController = controller
        controller.view.addSubview(tableView)
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        let message = item(identifier: "growing", text: "Short")
        coordinator.update(TanyaAIMessageListState(
            messages: [message, item(identifier: "next", text: "Following bubble")],
            isRestoring: false, isTypingRowVisible: false,
            suggestions: [], suggestionsTitle: nil
        ), theme: .sandbox, handlers: .inert)
        tableView.layoutIfNeeded()
        let original = tableView.rectForRow(at: IndexPath(row: 0, section: 0)).height
        message.update(content: .text(String(repeating: "A longer answer with several words. ", count: 20)))
        let settled = expectation(description: "Hosted layout updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { settled.fulfill() }
        wait(for: [settled], timeout: 2)
        tableView.layoutIfNeeded()
        let first = tableView.rectForRow(at: IndexPath(row: 0, section: 0))
        let second = tableView.rectForRow(at: IndexPath(row: 1, section: 0))
        XCTAssertGreaterThan(first.height, original + 40)
        XCTAssertGreaterThanOrEqual(second.minY, first.maxY)
    }

    func testPendingHeightUpdateDoesNotRetainTableOrCoordinator() {
        weak var releasedTable: TanyaAITrackingTableView?
        weak var releasedCoordinator: TanyaAIMessageTableView.Coordinator?
        weak var releasedMessage: TanyaAIMessageItemViewModel?
        autoreleasepool {
            let coordinator = TanyaAIMessageTableView.Coordinator()
            let tableView = TanyaAITrackingTableView(frame: .zero)
            coordinator.attach(tableView)
            let message = item(identifier: "pending", text: "Short")
            coordinator.update(TanyaAIMessageListState(
                messages: [message], isRestoring: false, isTypingRowVisible: false,
                suggestions: [], suggestionsTitle: nil
            ), theme: .sandbox, handlers: .inert)
            message.update(content: .text("Updated before teardown"))
            releasedTable = tableView
            releasedCoordinator = coordinator
            releasedMessage = message
        }
        XCTAssertNil(releasedTable)
        XCTAssertNil(releasedCoordinator)
        XCTAssertNil(releasedMessage)
    }

    private func item(identifier: String, text: String) -> TanyaAIMessageItemViewModel {
        TanyaAIMessageItemViewModel(message: TanyaAIMessage(
            identifier: identifier, role: .assistant, content: .text(text)
        ))
    }
}
