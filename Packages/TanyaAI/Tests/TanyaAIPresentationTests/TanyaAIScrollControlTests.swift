import DesignKit
import TanyaAIDomain
import UIKit
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIScrollControlTests: XCTestCase {
    func testVisibilityCoalescesAndReturnCancelsStaleUpdate() {
        let control = TanyaAIMessageScrollControl()
        control.updateVisibility(true)
        control.returnToLatest()
        let finished = expectation(description: "Next runloop")
        DispatchQueue.main.async { finished.fulfill() }
        wait(for: [finished], timeout: 1)
        XCTAssertFalse(control.isAwayFromLatest)
        XCTAssertEqual(control.requestIdentifier, 1)
    }

    func testDraggingCancelsQueuedFollowingAndButtonRestoresIt() {
        let coordinator = MessageTableView.Coordinator()
        let table = LayoutTrackingTableView(frame: CGRect(x: 0, y: 0, width: 375, height: 500), style: .plain)
        let control = TanyaAIMessageScrollControl()
        coordinator.attach(table)
        coordinator.updateScrollControl(control)
        coordinator.scheduleScrollToBottom(animated: false)
        coordinator.scrollViewWillBeginDragging(table)
        XCTAssertFalse(coordinator.isFollowingLatestMessage)
        control.returnToLatest()
        coordinator.updateScrollControl(control)
        XCTAssertTrue(coordinator.isFollowingLatestMessage)
    }

    func testScrollCoordinatorAndControlRelease() {
        weak var released: MessageTableView.Coordinator?
        weak var releasedControl: TanyaAIMessageScrollControl?
        autoreleasepool {
            let coordinator = MessageTableView.Coordinator()
            let control = TanyaAIMessageScrollControl()
            let table = LayoutTrackingTableView(frame: .zero, style: .plain)
            coordinator.attach(table)
            coordinator.updateScrollControl(control)
            control.updateVisibility(true)
            coordinator.scheduleScrollToBottom(animated: false)
            released = coordinator
            releasedControl = control
        }
        XCTAssertNil(released)
        XCTAssertNil(releasedControl)
    }
}
