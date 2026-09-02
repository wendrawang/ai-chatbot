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
    /// Set by the screen that opens the feature, consumed by the next
    /// `makeView`. Each presentation builds a fresh graph, so context does not
    /// leak from one presentation into the next.
    private var pendingContext: TanyaAIContext?

    init(
        dependencies: TanyaAIDependencies,
        configuration: TanyaAIConfiguration
    ) {
        self.dependencies = dependencies
        self.configuration = configuration
    }

    /// Registers what happens when a bubble hands a deeplink to the host.
    /// Set once by the scene; the gateway itself does not interpret it.
    func onAction(_ handler: @escaping (TanyaAIAction) -> Void) {
        actionHandler = handler
    }

    /// Opens the feature carrying the originating screen's context.
    func presentTanyaAI(context: TanyaAIContext?) {
        pendingContext = context
        presentTanyaAI()
    }

    /// Opens the feature. The binding drives `fullScreenCover` in the host
    /// screen, so presentation stays a host decision.
    func presentTanyaAI() {
        performOnMain { [weak self] in
            self?.isPresented = true
        }
    }

    /// Closes the feature. Called by the feature's own close button and by
    /// the deeplink router before it pushes a destination.
    func dismissTanyaAI() {
        performOnMain { [weak self] in
            self?.isPresented = false
        }
    }

    /// Builds a fresh feature graph for one presentation. Never cached: each
    /// presentation gets its own router, ViewModels, and stream.
    func makeView() -> TanyaAIRootView {
        TanyaAIModule.makeView(
            configuration: TanyaAIConfiguration(
                messagePath: configuration.messagePath,
                initialPrompt: configuration.initialPrompt,
                context: pendingContext ?? configuration.context
            ),
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
