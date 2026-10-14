import SwiftUI
import UIKit
import XCTest

@testable import TanyaAIPresentation

@MainActor
final class TanyaAIFrameRateTests: XCTestCase {
    /// Regression proxy: CADisplayLink callback cadence, not GPU-rendered FPS.
    private static let target = 55.0
    private static let sampleCount = 3

    func testLargeConversationMaintainsDisplayLinkCadence() {
        XCTAssertTrue(Thread.isMainThread)
        let harness = makeHarness(messageCount: 120)
        let tableView = findTableView(in: harness.controller.view)
        XCTAssertNotNil(tableView)
        // 120 incoming messages exercise eviction; 100 messages plus typing and timestamp remain.
        XCTAssertEqual(tableView?.numberOfRows(inSection: 0), 102)
        XCTAssertEqual(
            tableView?.separatorStyle,
            UITableViewCell.SeparatorStyle.none
        )

        let samples = (0..<Self.sampleCount).map { _ in
            sampleFramesPerSecond(scrolling: tableView)
        }
        let median = samples.sorted()[samples.count / 2]
        print("TANYA_AI_DISPLAY_LINK_MEDIAN=\(median) samples=\(samples)")
        XCTAssertGreaterThanOrEqual(
            median,
            Self.target,
            "Median callback cadence was below target: \(samples)"
        )
        withExtendedLifetime(harness) {}
    }

    /// One scroll, measured. Returns to the top afterwards so the next sample
    /// has the same distance to travel as the first.
    private func sampleFramesPerSecond(
        scrolling tableView: UITableView?
    ) -> Double {
        tableView?.setContentOffset(.zero, animated: false)
        let monitor = TanyaAIFrameRateMonitor()
        let completed = expectation(description: "Frame-rate sample completed")
        var measured = 0.0
        monitor.start()
        animateScroll(tableView)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            measured = monitor.stop()
            completed.fulfill()
        }
        wait(for: [completed], timeout: 2)
        return measured
    }

    private func makeHarness(messageCount: Int) -> ViewHarness {
        let repository = TanyaAIRepositoryFixture()
        let viewModel = TanyaAIChatViewModel(repository: repository)
        viewModel.sendMessage("performance fixture")
        repository.appendMessages(count: messageCount)

        let controller = UIHostingController(
            rootView: ChatScreen(viewModel: viewModel)
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
