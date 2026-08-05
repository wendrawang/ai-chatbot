import SwiftUI
import UIKit
import XCTest
@testable import TanyaAIPresentation

final class TanyaAIFrameRateTests: XCTestCase {
    func testTwoThousandMessageScrollMaintainsRefreshBaseline() {
        XCTAssertTrue(Thread.isMainThread)
        let harness = makeHarness(messageCount: 2_000)
        let scrollView = largestScrollView(in: harness.controller.view)
        XCTAssertNotNil(scrollView)

        let baselineRate = measureFrames(description: "Idle baseline") {}
        let scrollRate = measureFrames(description: "Chat scroll") {
            animateScroll(scrollView)
        }
        print("TANYA_AI_BASELINE_FPS=\(baselineRate)")
        print("TANYA_AI_SCROLL_FPS=\(scrollRate)")

        XCTAssertGreaterThan(baselineRate, 0)
        XCTAssertGreaterThanOrEqual(scrollRate, baselineRate * 0.97)
        withExtendedLifetime(harness) {}
    }

    private func measureFrames(
        description: String,
        action: () -> Void
    ) -> Double {
        let monitor = TanyaAIFrameRateMonitor()
        let completed = expectation(description: description)
        monitor.start()
        action()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completed.fulfill()
        }
        wait(for: [completed], timeout: 3)
        return monitor.stop()
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
        controller.view.layoutIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        return ViewHarness(window: window, controller: controller)
    }

    private func animateScroll(_ scrollView: UIScrollView?) {
        guard let scrollView = scrollView else {
            return
        }
        let maximumOffset = max(
            0,
            scrollView.contentSize.height - scrollView.bounds.height
        )
        let stressDistance = scrollView.bounds.height * 6
        let targetOffset = min(maximumOffset, stressDistance)

        UIView.animate(
            withDuration: 1.2,
            delay: 0,
            options: [.curveLinear, .allowUserInteraction]
        ) {
            scrollView.contentOffset = CGPoint(x: 0, y: targetOffset)
        }
    }

    private func largestScrollView(in view: UIView) -> UIScrollView? {
        let childViews = view.subviews.flatMap(allViews)
        return ([view] + childViews)
            .compactMap { $0 as? UIScrollView }
            .max { $0.contentSize.height < $1.contentSize.height }
    }

    private func allViews(_ view: UIView) -> [UIView] {
        [view] + view.subviews.flatMap(allViews)
    }
}

private struct ViewHarness {
    let window: UIWindow
    let controller: UIViewController
}
