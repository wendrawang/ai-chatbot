import SwiftUI
import UIKit
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIFrameRateTests: XCTestCase {
    func testLargeConversationScrollsAtSixtyFrameTarget() {
        XCTAssertTrue(Thread.isMainThread)
        let harness = makeHarness(messageCount: 120)
        let tableView = findTableView(in: harness.controller.view)
        XCTAssertNotNil(tableView)
        XCTAssertEqual(
            tableView?.separatorStyle,
            UITableViewCell.SeparatorStyle.none
        )

        let monitor = TanyaAIFrameRateMonitor()
        let completed = expectation(description: "Frame-rate sample completed")
        monitor.start()
        animateScroll(tableView)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let framesPerSecond = monitor.stop()
            print("TANYA_AI_MEASURED_FPS=\(framesPerSecond)")
            XCTAssertGreaterThanOrEqual(framesPerSecond, 55)
            completed.fulfill()
        }
        wait(for: [completed], timeout: 2)
        withExtendedLifetime(harness) {}
    }

    private func makeHarness(messageCount: Int) -> ViewHarness {
        let useCase = TanyaAIChatUseCaseFixture()
        let viewModel = TanyaAIChatViewModel(useCase: useCase)
        viewModel.sendMessage("performance fixture")
        useCase.appendStatusMessages(count: messageCount)

        let controller = UIHostingController(
            rootView: TanyaAIChatView(viewModel: viewModel)
        )
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        return ViewHarness(window: window, controller: controller)
    }

    private func animateScroll(_ tableView: UITableView?) {
        guard let tableView = tableView else {
            return
        }
        let maximumOffset = max(
            0,
            tableView.contentSize.height - tableView.bounds.height
        )
        tableView.setContentOffset(
            CGPoint(x: 0, y: maximumOffset),
            animated: true
        )
    }

    private func findTableView(in view: UIView) -> UITableView? {
        if let tableView = view as? UITableView {
            return tableView
        }
        for subview in view.subviews {
            if let tableView = findTableView(in: subview) {
                return tableView
            }
        }
        return nil
    }
}

private struct ViewHarness {
    let window: UIWindow
    let controller: UIViewController
}
