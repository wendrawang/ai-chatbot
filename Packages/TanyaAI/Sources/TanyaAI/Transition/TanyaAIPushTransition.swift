//
//  TanyaAIPushTransition.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

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
