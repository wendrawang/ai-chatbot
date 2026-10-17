//
//  TanyaAIPushTransitionTests.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import UIKit
import XCTest

@testable import TanyaAI

/// How the feature arrives. It is presented rather than pushed - staying out
/// of the host's navigation stack is the point - so the push has to be the
/// animation's doing.
@MainActor
final class TanyaAIPushTransitionTests: XCTestCase {
    func testPresentingAndDismissingUseOppositeDirections() {
        let transition = TanyaAIPushTransition()
        let presenting =
            transition.animationController(
                forPresented: UIViewController(),
                presenting: UIViewController(),
                source: UIViewController()
            ) as? TanyaAIPushAnimator
        let dismissing =
            transition.animationController(
                forDismissed: UIViewController()
            ) as? TanyaAIPushAnimator

        XCTAssertNotNil(presenting)
        XCTAssertNotNil(dismissing)
        XCTAssertNotEqual(
            presenting?.isPresenting,
            dismissing?.isPresenting
        )
    }

    func testTheAnimationTakesTime() {
        let animator = TanyaAIPushAnimator(isPresenting: true)

        if UIAccessibility.isReduceMotionEnabled {
            XCTAssertEqual(animator.transitionDuration(using: nil), 0)
        } else {
            XCTAssertGreaterThan(animator.transitionDuration(using: nil), 0)
        }
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
        while context.isCompleted == nil, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }

        XCTAssertEqual(context.isCompleted, true)
        XCTAssertEqual(leaving.view.transform, .identity)
        XCTAssertEqual(arriving.view.transform, .identity)
    }

    func testCoveredHostIsHiddenAfterPresentationAndShownForDismissal() {
        let host = UIViewController()
        let feature = UIViewController()
        let presenting = TanyaAITransitionContextSpy(
            container: UIView(frame: CGRect(x: 0, y: 0, width: 390, height: 844)),
            leaving: host, arriving: feature, hiddenHostKey: .from
        )
        run(TanyaAIPushAnimator(isPresenting: true), in: presenting)
        XCTAssertTrue(host.view.isHidden)
        let dismissing = TanyaAITransitionContextSpy(
            container: UIView(frame: CGRect(x: 0, y: 0, width: 390, height: 844)),
            leaving: feature, arriving: host, hiddenHostKey: .to
        )
        run(TanyaAIPushAnimator(isPresenting: false), in: dismissing)
        XCTAssertFalse(host.view.isHidden)
        XCTAssertNil(host.view.superview)
    }

    func testCancelledSwipeRestoresTheCoveredHost() {
        let host = UIViewController()
        let feature = UIViewController()
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        let fullScreen = TanyaAITransitionContextSpy(
            container: container, leaving: feature, arriving: host, isCancelled: true
        )
        run(TanyaAIPushAnimator(isPresenting: false), in: fullScreen)
        XCTAssertEqual(fullScreen.isCompleted, false)
        XCTAssertNil(host.view.superview)
        XCTAssertEqual(host.view.transform, .identity)
        let overFullScreen = TanyaAITransitionContextSpy(
            container: container, leaving: feature, arriving: host, isCancelled: true, hiddenHostKey: .to
        )
        run(TanyaAIPushAnimator(isPresenting: false), in: overFullScreen)
        XCTAssertTrue(host.view.isHidden)
        XCTAssertEqual(feature.view.transform, .identity)
    }

    func testSwipeBackIsInteractiveOnlyWhileTheFingerDrivesIt() {
        let transition = TanyaAIPushTransition()
        let animator = TanyaAIPushAnimator(isPresenting: false)
        XCTAssertNil(transition.interactionControllerForDismissal(using: animator))
        transition.interaction.isInteracting = true
        XCTAssertTrue(transition.interactionControllerForDismissal(using: animator) === transition.interaction)
        let view = UIView()
        transition.interaction.attach(to: view) {}
        let edges = view.gestureRecognizers?.compactMap { ($0 as? UIScreenEdgePanGestureRecognizer)?.edges }
        XCTAssertEqual(edges, [.left])
    }

    private func run(_ animator: TanyaAIPushAnimator, in context: TanyaAITransitionContextSpy) {
        animator.animateTransition(using: context)
        let deadline = Date().addingTimeInterval(2)
        while context.isCompleted == nil, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
    }
}

/// Enough of `UIViewControllerContextTransitioning` for the animator to run.
private final class TanyaAITransitionContextSpy:
    NSObject, UIViewControllerContextTransitioning
{
    let containerView: UIView
    private(set) var isCompleted: Bool?
    private let leaving: UIViewController
    private let arriving: UIViewController
    private let hiddenHostKey: UITransitionContextViewKey?

    /// `hiddenHostKey` meniru overFullScreen: UIKit tidak menyerahkan view host ke container.
    init(
        container: UIView,
        leaving: UIViewController,
        arriving: UIViewController,
        isCancelled: Bool = false,
        hiddenHostKey: UITransitionContextViewKey? = nil
    ) {
        containerView = container
        self.leaving = leaving
        self.arriving = arriving
        self.hiddenHostKey = hiddenHostKey
        transitionWasCancelled = isCancelled
        super.init()
    }

    func viewController(
        forKey key: UITransitionContextViewControllerKey
    ) -> UIViewController? {
        key == .from ? leaving : arriving
    }

    func completeTransition(_ isCompleted: Bool) {
        self.isCompleted = isCompleted
    }

    let isAnimated = true
    let isInteractive = false
    // Required spelling from UIViewControllerContextTransitioning.
    // swiftlint:disable:next boolean_prefix
    let transitionWasCancelled: Bool
    let presentationStyle = UIModalPresentationStyle.fullScreen
    let targetTransform = CGAffineTransform.identity

    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        guard key != hiddenHostKey else { return nil }
        return key == .from ? leaving.view : arriving.view
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
