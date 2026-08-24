public enum TanyaAIModule {
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
