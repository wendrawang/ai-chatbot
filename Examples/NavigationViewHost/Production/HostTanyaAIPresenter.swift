import Combine
import Foundation

/// What the existing screens and coordinators depend on.
///
/// Legacy screens stay unaware of Tanya AI: they only ask the presenter to
/// open or close the feature.
protocol HostTanyaAIPresenting: AnyObject {
    func presentTanyaAI()
    func dismissTanyaAI()
}

/// Presentation state for one scene.
///
/// It holds a flag, not the feature graph. `TanyaAIModule.makeView` is called
/// by the `fullScreenCover` closure, so each presentation gets a fresh graph.
final class HostTanyaAIPresenter: ObservableObject, HostTanyaAIPresenting {
    @Published var isPresented = false

    func presentTanyaAI() {
        performOnMain { [weak self] in
            self?.isPresented = true
        }
    }

    func dismissTanyaAI() {
        performOnMain { [weak self] in
            self?.isPresented = false
        }
    }

    private func performOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
