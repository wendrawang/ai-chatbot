import UIKit

/// Makes the feature arrive like a pushed page instead of a sheet rising from
/// the bottom.
///
/// It is still presented, not pushed. Staying out of the host's navigation
/// stack is the whole reason the feature is a controller of its own: a host
/// built on `NavigationView` drops a push that starts while a pop is still
/// running, and that failure is silent. This changes only how it moves, so the
/// isolation survives and the motion still reads as a page.
final class TanyaAIPushTransition: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        TanyaAIPushAnimator(isPresenting: true)
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        TanyaAIPushAnimator(isPresenting: false)
    }
}

/// The two halves of a navigation push: the arriving page slides in from the
/// trailing edge while the page behind it drifts a shorter distance the other
/// way, which is what gives a push its depth.
final class TanyaAIPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    /// How far the outgoing page travels, as a fraction of the incoming one.
    /// `UINavigationController` uses roughly a third.
    private static let parallax: CGFloat = 0.3
    private static let duration: TimeInterval = 0.35

    private let isPresenting: Bool

    /// Which half this animator is, so a test can tell the two apart without
    /// running an animation.
    var isPresentingForTests: Bool { isPresenting }

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        Self.duration
    }

    func animateTransition(
        using context: UIViewControllerContextTransitioning
    ) {
        guard let leaving = context.viewController(forKey: .from),
              let arriving = context.viewController(forKey: .to) else {
            context.completeTransition(false)
            return
        }
        let container = context.containerView
        let width = container.bounds.width
        // The page arrives from the side the language reads towards.
        let direction: CGFloat = container
            .effectiveUserInterfaceLayoutDirection == .rightToLeft ? -1 : 1

        if isPresenting {
            present(
                arriving,
                over: leaving,
                width: width * direction,
                context: context
            )
        } else {
            dismiss(
                leaving,
                revealing: arriving,
                width: width * direction,
                context: context
            )
        }
    }

    private func present(
        _ arriving: UIViewController,
        over leaving: UIViewController,
        width: CGFloat,
        context: UIViewControllerContextTransitioning
    ) {
        let container = context.containerView
        arriving.view.frame = container.bounds
        arriving.view.transform = CGAffineTransform(translationX: width, y: 0)
        container.addSubview(arriving.view)

        animate {
            arriving.view.transform = .identity
            leaving.view.transform = CGAffineTransform(
                translationX: -width * Self.parallax,
                y: 0
            )
        } completion: {
            // The host reuses this view once the feature is over, so it
            // cannot be left displaced.
            leaving.view.transform = .identity
            context.completeTransition(
                context.transitionWasCancelled == false
            )
        }
    }

    private func dismiss(
        _ leaving: UIViewController,
        revealing arriving: UIViewController,
        width: CGFloat,
        context: UIViewControllerContextTransitioning
    ) {
        let container = context.containerView
        arriving.view.frame = container.bounds
        arriving.view.transform = CGAffineTransform(
            translationX: -width * Self.parallax,
            y: 0
        )
        container.insertSubview(arriving.view, belowSubview: leaving.view)

        animate {
            arriving.view.transform = .identity
            leaving.view.transform = CGAffineTransform(
                translationX: width,
                y: 0
            )
        } completion: {
            leaving.view.transform = .identity
            context.completeTransition(
                context.transitionWasCancelled == false
            )
        }
    }

    /// Whether the animation ran to its last frame is deliberately not
    /// consulted.
    ///
    /// `UIView` reports `finished: false` whenever it did not animate all the
    /// way - a view with no window, an interrupted transition - and reporting
    /// that back as a failed transition leaves UIKit believing the
    /// presentation never happened. Only a cancelled transition is a failure,
    /// and a non-interactive one is never cancelled.
    private func animate(
        _ changes: @escaping () -> Void,
        completion: @escaping () -> Void
    ) {
        UIView.animate(
            withDuration: Self.duration,
            delay: 0,
            options: [.curveEaseInOut],
            animations: changes,
            completion: { _ in completion() }
        )
    }
}
