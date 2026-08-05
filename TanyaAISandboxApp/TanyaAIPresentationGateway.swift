import Combine
import Foundation
import TanyaAI

final class TanyaAIPresentationGateway:
    ObservableObject,
    TanyaAIPresenting {

    @Published var isPresented = false

    private let dependencies: TanyaAIDependencies
    private let configuration: TanyaAIConfiguration

    init(
        dependencies: TanyaAIDependencies,
        configuration: TanyaAIConfiguration
    ) {
        self.dependencies = dependencies
        self.configuration = configuration
    }

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

    func makeView() -> TanyaAIRootView {
        TanyaAIModule.makeView(
            configuration: configuration,
            dependencies: dependencies,
            onClose: { [weak self] in
                self?.dismissTanyaAI()
            }
        )
    }

    private func performOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
