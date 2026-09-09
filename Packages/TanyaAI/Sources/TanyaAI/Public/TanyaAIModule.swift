import UIKit

public enum TanyaAIModule {
    /// Builds one isolated feature graph and its entry controller.
    ///
    /// - Parameters:
    ///   - configuration: relative message path and optional initial prompt.
    ///   - dependencies: host transport, authorization service, and theme.
    ///   - onAction: called with the deeplink a bubble asks the host to open.
    ///     The feature does not open it, does not dismiss itself, and does not
    ///     navigate. Validate the deeplink here and drop anything the app does
    ///     not recognise.
    ///
    /// Call it once per presentation. It is a factory, not a singleton.
    public static func makeViewController(
        configuration: TanyaAIConfiguration = TanyaAIConfiguration(),
        dependencies: TanyaAIDependencies,
        onAction: @escaping (TanyaAIAction) -> Void = { _ in }
    ) -> UIViewController {
        let dependencyContainer = TanyaAIDependencyContainer(
            configuration: configuration,
            dependencies: dependencies
        )
        return TanyaAIContainerViewController(
            dependencyContainer: dependencyContainer,
            actionHandler: onAction
        )
    }
}
