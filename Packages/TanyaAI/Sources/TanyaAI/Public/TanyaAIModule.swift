public enum TanyaAIModule {
    /// Builds one isolated feature graph.
    ///
    /// - Parameters:
    ///   - configuration: relative message path and optional initial prompt.
    ///   - dependencies: host transport, authorization service, and theme.
    ///   - onClose: called when the user closes the feature. The host owns the
    ///     dismissal, so nothing happens unless it acts.
    ///   - onAction: called with the deeplink a bubble asks the host to open.
    ///     The feature does not open it, does not dismiss itself, and does not
    ///     navigate. Validate the deeplink here and drop anything the app does
    ///     not recognise.
    ///
    /// Call it once per presentation. It is a factory, not a singleton.
    public static func makeView(
        configuration: TanyaAIConfiguration = TanyaAIConfiguration(),
        dependencies: TanyaAIDependencies,
        onClose: @escaping () -> Void = {},
        onAction: @escaping (TanyaAIAction) -> Void = { _ in }
    ) -> TanyaAIRootView {
        let dependencyContainer = TanyaAIDependencyContainer(
            configuration: configuration,
            dependencies: dependencies
        )
        return TanyaAIRootView(
            dependencyContainer: dependencyContainer,
            closeHandler: onClose,
            actionHandler: onAction
        )
    }
}
