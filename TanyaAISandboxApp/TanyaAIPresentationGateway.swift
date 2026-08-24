import Combine
import Foundation
import TanyaAI

final class TanyaAIPresentationGateway:
    ObservableObject,
    TanyaAIPresenting {

    @Published var isPresented = false

    private let dependencies: TanyaAIDependencies
    private let configuration: TanyaAIConfiguration
    private var actionHandler: ((TanyaAIAction) -> Void)?

    init(
        dependencies: TanyaAIDependencies,
        configuration: TanyaAIConfiguration
    ) {
        self.dependencies = dependencies
        self.configuration = configuration
    }

    func onAction(_ handler: @escaping (TanyaAIAction) -> Void) {
        actionHandler = handler
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
            },
            onAction: { [weak self] action in
                self?.actionHandler?(action)
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
