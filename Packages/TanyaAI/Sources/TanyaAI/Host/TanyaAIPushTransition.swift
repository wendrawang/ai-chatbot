//
//  TanyaAIPushTransition.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import UIKit

/// Makes the feature arrive like a pushed page instead of a sheet rising from
/// the bottom.
///
/// It is still presented, not pushed. Staying out of the host's navigation
/// stack is the whole reason the feature is a controller of its own: a host
/// built on `NavigationView` drops a push that starts while a pop is still
/// running, and that failure is silent. This changes only how it moves, so the
/// isolation survives and the motion still reads as a page.
@MainActor
final class TanyaAIPushTransition: NSObject, UIViewControllerTransitioningDelegate {
    let interaction = TanyaAIPushInteraction()

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

    /// Hanya swipe-back yang interaktif; tombol back dan dismiss host memakai animasi biasa.
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interaction.isInteracting ? interaction : nil
    }
}

/// The two halves of a navigation push: the arriving page slides in from the
/// trailing edge while the page behind it drifts a shorter distance the other
/// way, which is what gives a push its depth.
final class TanyaAIPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private static let forwardDirection: CGFloat = 1
    /// How far the outgoing page travels, as a fraction of the incoming one.
    /// `UINavigationController` uses roughly a third.
    private static let parallax: CGFloat = CustomMotion.Navigation.parallax
    private static let duration: TimeInterval = CustomMotion.Navigation.duration

    let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        UIAccessibility.isReduceMotionEnabled ? TimeInterval.zero : Self.duration
    }

    func animateTransition(
        using context: UIViewControllerContextTransitioning
    ) {
        guard let leaving = context.viewController(forKey: .from),
            let arriving = context.viewController(forKey: .to)
        else {
            context.completeTransition(false)
            return
        }
        let container = context.containerView
        let width = UIAccessibility.isReduceMotionEnabled ? .zero : container.bounds.width
        // The page arrives from the side the language reads towards.
        let direction: CGFloat =
            container
                .effectiveUserInterfaceLayoutDirection == .rightToLeft
            ? -Self.forwardDirection : Self.forwardDirection

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
        arriving.view.transform = CGAffineTransform(translationX: width, y: .zero)
        container.addSubview(arriving.view)

        animate {
            arriving.view.transform = .identity
            leaving.view.transform = CGAffineTransform(
                translationX: -width * Self.parallax,
                y: .zero
            )
        } completion: {
            // The host reuses this view once the feature is over, so it
            // cannot be left displaced.
            leaving.view.transform = .identity
            // Host tetap di window agar SwiftUI terus memproses perubahan root (mis. logout),
            // tetapi disembunyikan: tidak di-render dan tidak terbaca VoiceOver di belakang fitur.
            leaving.view.isHidden = context.view(forKey: .from) == nil
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
            y: .zero
        )
        // overFullScreen membiarkan view host tetap di window; fullScreen menyerahkannya ke container.
        let isHostInContainer = context.view(forKey: .to) != nil
        if isHostInContainer { container.insertSubview(arriving.view, belowSubview: leaving.view) }
        arriving.view.isHidden = false

        animate {
            arriving.view.transform = .identity
            leaving.view.transform = CGAffineTransform(
                translationX: width,
                y: .zero
            )
        } completion: {
            leaving.view.transform = .identity
            arriving.view.transform = .identity
            // Swipe yang dibatalkan: halaman host kembali tersembunyi seperti sebelum dismiss dimulai.
            if context.transitionWasCancelled {
                if isHostInContainer { arriving.view.removeFromSuperview() } else { arriving.view.isHidden = true }
            }
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
            withDuration: transitionDuration(using: nil),
            delay: .zero,
            options: [.curveEaseInOut],
            animations: changes,
            completion: { _ in completion() }
        )
    }
}
