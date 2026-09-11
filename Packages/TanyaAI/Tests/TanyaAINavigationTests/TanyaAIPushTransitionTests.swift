import UIKit
import XCTest
@testable import TanyaAI

/// How the feature arrives. It is presented rather than pushed - staying out
/// of the host's navigation stack is the point - so the push has to be the
/// animation's doing.
final class TanyaAIPushTransitionTests: XCTestCase {
    func testPresentingAndDismissingUseOppositeDirections() {
        let transition = TanyaAIPushTransition()
        let presenting = transition.animationController(
            forPresented: UIViewController(),
            presenting: UIViewController(),
            source: UIViewController()
        ) as? TanyaAIPushAnimator
        let dismissing = transition.animationController(
            forDismissed: UIViewController()
        ) as? TanyaAIPushAnimator

        XCTAssertNotNil(presenting)
        XCTAssertNotNil(dismissing)
        XCTAssertNotEqual(
            presenting?.isPresentingForTests,
            dismissing?.isPresentingForTests
        )
    }

    func testTheAnimationTakesTime() {
        let animator = TanyaAIPushAnimator(isPresenting: true)

        XCTAssertGreaterThan(animator.transitionDuration(using: nil), 0)
    }

    /// Two things at once, both of which have bitten.
    ///
    /// The presenting view is handed back to the host afterwards, so it must
    /// not be left displaced. And the transition has to report success: these
    /// views have no window, so `UIView` reports the animation as unfinished,
    /// and passing that straight through leaves UIKit believing the
    /// presentation never happened.
    func testPresentingLeavesTheHostViewWhereItFoundIt() {
        let container = UIView(
            frame: CGRect(x: 0, y: 0, width: 390, height: 844)
        )
        let leaving = UIViewController()
        let arriving = UIViewController()
        let context = TanyaAITransitionContextSpy(
            container: container,
            leaving: leaving,
            arriving: arriving
        )

        TanyaAIPushAnimator(isPresenting: true).animateTransition(using: context)
        // The completion runs when the animation does; drain the loop so it
        // has, rather than asserting on a state that has not happened yet.
        let deadline = Date().addingTimeInterval(2)
        while context.completed == nil, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }

        XCTAssertEqual(context.completed, true)
        XCTAssertEqual(leaving.view.transform, .identity)
        XCTAssertEqual(arriving.view.transform, .identity)
    }
}

/// Enough of `UIViewControllerContextTransitioning` for the animator to run.
private final class TanyaAITransitionContextSpy:
    NSObject, UIViewControllerContextTransitioning {
    let containerView: UIView
    private(set) var completed: Bool?
    private let leaving: UIViewController
    private let arriving: UIViewController

    init(
        container: UIView,
        leaving: UIViewController,
        arriving: UIViewController
    ) {
        containerView = container
        self.leaving = leaving
        self.arriving = arriving
        super.init()
    }

    func viewController(
        forKey key: UITransitionContextViewControllerKey
    ) -> UIViewController? {
        key == .from ? leaving : arriving
    }

    func completeTransition(_ didComplete: Bool) {
        completed = didComplete
    }

    let isAnimated = true
    let isInteractive = false
    let transitionWasCancelled = false
    let presentationStyle = UIModalPresentationStyle.fullScreen
    let targetTransform = CGAffineTransform.identity

    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        key == .from ? leaving.view : arriving.view
    }

    func initialFrame(for viewController: UIViewController) -> CGRect {
        containerView.bounds
    }

    func finalFrame(for viewController: UIViewController) -> CGRect {
        containerView.bounds
    }

    func updateInteractiveTransition(_ percentComplete: CGFloat) {}
    func finishInteractiveTransition() {}
    func cancelInteractiveTransition() {}
    func pauseInteractiveTransition() {}
}
