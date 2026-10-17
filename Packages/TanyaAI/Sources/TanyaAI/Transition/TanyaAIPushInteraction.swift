//
//  TanyaAIPushInteraction.swift
//  TanyaAI
//
//  Created by Wendra on 17/10/26.
//

import DesignKit
import UIKit

/// Swipe dari tepi awal layar untuk kembali, seperti pop UINavigationController.
/// Geseran bisa dibatalkan di tengah jalan; Reduce Motion memakai dismiss biasa tanpa animasi geser.
@MainActor
final class TanyaAIPushInteraction: UIPercentDrivenInteractiveTransition {
    /// True hanya selama jari menggerakkan dismissal. Internal agar test dapat mensimulasikan swipe.
    var isInteracting = false
    private var onSwipeBack: (() -> Void)?

    /// Satu gesture per presentasi; closure memulai dismiss milik host.
    func attach(to view: UIView, onSwipeBack: @escaping () -> Void) {
        self.onSwipeBack = onSwipeBack
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        gesture.edges = isRightToLeft(view) ? .right : .left
        view.addGestureRecognizer(gesture)
    }

    @objc
    private func handleSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let view = gesture.view else { return }
        switch gesture.state {
        case .began:
            isInteracting = !UIAccessibility.isReduceMotionEnabled
            onSwipeBack?()
        case .changed:
            guard isInteracting else { return }
            update(progress(of: gesture, in: view))
        case .ended:
            guard isInteracting else { return }
            isInteracting = false
            if shouldFinish(gesture, in: view) { finish() } else { cancel() }
        case .cancelled, .failed:
            guard isInteracting else { return }
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

    /// Jarak geser ke arah kembali, dinormalisasi terhadap lebar layar (0...1).
    func progress(of gesture: UIScreenEdgePanGestureRecognizer, in view: UIView) -> CGFloat {
        guard view.bounds.width > .zero else { return .zero }
        let distance = forward(gesture.translation(in: view).x, in: view)
        return min(max(distance / view.bounds.width, .zero), 1)
    }

    func shouldFinish(_ gesture: UIScreenEdgePanGestureRecognizer, in view: UIView) -> Bool {
        let velocity = forward(gesture.velocity(in: view).x, in: view)
        return progress(of: gesture, in: view) > CustomMotion.SwipeBack.progress
            || velocity > CustomMotion.SwipeBack.velocity
    }

    func forward(_ value: CGFloat, in view: UIView) -> CGFloat {
        isRightToLeft(view) ? -value : value
    }
}
