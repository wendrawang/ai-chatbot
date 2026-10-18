//
//  TanyaAIPushTransition.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import UIKit

/// Membuat Tanya AI tampil seperti halaman biasa: geser dari samping dan bisa swipe-back.
/// Fitur tetap dipresentasikan (bukan push) agar terpisah dari navigation stack host;
/// modal bawaan UIKit hanya bisa naik dari bawah, jadi animasinya disediakan di sini.
@MainActor
final class TanyaAIPushTransition: NSObject, UIViewControllerTransitioningDelegate {
    let interaction = TanyaAIPushInteraction()

    func animationController(
        forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        TanyaAIPushAnimator(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TanyaAIPushAnimator(isPresenting: false)
    }

    /// Hanya swipe-back yang interaktif; tombol back dan dismiss host memakai animasi biasa.
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interaction.isInteracting ? interaction : nil
    }
}

/// Halaman fitur masuk dari arah bacaan; halaman host bergeser sebagian (parallax) ke arah sebaliknya.
final class TanyaAIPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        UIAccessibility.isReduceMotionEnabled ? .zero : CustomMotion.Navigation.duration
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        guard let leaving = context.viewController(forKey: .from),
            let arriving = context.viewController(forKey: .to)
        else {
            context.completeTransition(false)
            return
        }
        let page = isPresenting ? arriving : leaving
        let host = isPresenting ? leaving : arriving
        let container = context.containerView
        // .fullScreen menyerahkan view host ke container; .overFullScreen membiarkannya di window.
        let isHostInContainer = context.view(forKey: isPresenting ? .from : .to) != nil
        host.view.isHidden = false
        if isPresenting {
            page.view.frame = container.bounds
            container.addSubview(page.view)
        } else if isHostInContainer {
            host.view.frame = container.bounds
            container.insertSubview(host.view, belowSubview: page.view)
        }
        let offset = pageOffset(in: container)
        let pageAside = CGAffineTransform(translationX: offset, y: .zero)
        let hostAside = CGAffineTransform(translationX: -offset * CustomMotion.Navigation.parallax, y: .zero)
        page.view.transform = isPresenting ? pageAside : .identity
        host.view.transform = isPresenting ? .identity : hostAside
        UIView.animate(withDuration: transitionDuration(using: context), delay: .zero, options: [.curveEaseInOut]) {
            page.view.transform = self.isPresenting ? .identity : pageAside
            host.view.transform = self.isPresenting ? hostAside : .identity
        } completion: { _ in
            // Flag `finished` sengaja diabaikan: tanpa window UIKit melaporkan false, padahal
            // hanya transisi yang dibatalkan yang gagal.
            self.finish(page: page, host: host, isHostInContainer: isHostInContainer, context: context)
        }
    }
}

// MARK: - Helpers

private extension TanyaAIPushAnimator {
    /// Lebar layar ke arah bacaan (positif LTR, negatif RTL); nol saat Reduce Motion.
    func pageOffset(in container: UIView) -> CGFloat {
        guard !UIAccessibility.isReduceMotionEnabled else { return .zero }
        let width = container.bounds.width
        return container.effectiveUserInterfaceLayoutDirection == .rightToLeft ? -width : width
    }

    func finish(
        page: UIViewController, host: UIViewController, isHostInContainer: Bool,
        context: UIViewControllerContextTransitioning
    ) {
        page.view.transform = .identity
        host.view.transform = .identity
        let isCancelled = context.transitionWasCancelled
        // Host tertutup fitur setelah present berhasil atau swipe-back batal.
        if isPresenting != isCancelled {
            if isHostInContainer && !isPresenting { host.view.removeFromSuperview() }
            // Tetap di window agar SwiftUI host terus update (mis. logout), tetapi tidak di-render.
            if !isHostInContainer { host.view.isHidden = true }
        }
        context.completeTransition(!isCancelled)
    }
}

/// Swipe dari tepi awal layar untuk kembali; bisa dibatalkan di tengah jalan.
/// Dengan Reduce Motion, swipe langsung menutup tanpa animasi geser.
@MainActor
final class TanyaAIPushInteraction: UIPercentDrivenInteractiveTransition {
    /// True hanya selama jari menggerakkan dismissal. Internal agar test dapat mensimulasikan swipe.
    var isInteracting = false
    private var onSwipeBack: (() -> Void)?

    func attach(to view: UIView, onSwipeBack: @escaping () -> Void) {
        self.onSwipeBack = onSwipeBack
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        gesture.edges = isRightToLeft(view) ? .right : .left
        view.addGestureRecognizer(gesture)
    }

    @objc
    private func handleSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let width = view.bounds.width
        let distance = max(.zero, min(forward(gesture.translation(in: view).x, in: view), width))
        let progress = width > .zero ? distance / width : .zero
        switch gesture.state {
        case .began:
            isInteracting = !UIAccessibility.isReduceMotionEnabled
            onSwipeBack?()
        case .changed where isInteracting:
            update(progress)
        case .ended where isInteracting:
            isInteracting = false
            let velocity = forward(gesture.velocity(in: view).x, in: view)
            let isFinishing = progress > CustomMotion.SwipeBack.progress || velocity > CustomMotion.SwipeBack.velocity
            if isFinishing { finish() } else { cancel() }
        case .cancelled where isInteracting, .failed where isInteracting:
            isInteracting = false
            cancel()
        default:
            break
        }
    }
}

// MARK: - Helpers

private extension TanyaAIPushInteraction {
    func isRightToLeft(_ view: UIView) -> Bool {
        UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == .rightToLeft
    }

    /// Nilai ke arah kembali: positif saat menggeser menjauhi tepi awal.
    func forward(_ value: CGFloat, in view: UIView) -> CGFloat {
        isRightToLeft(view) ? -value : value
    }
}
