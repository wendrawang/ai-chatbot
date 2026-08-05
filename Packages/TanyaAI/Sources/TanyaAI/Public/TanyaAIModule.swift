public enum TanyaAIModule {
    public static func makeView(
        configuration: TanyaAIConfiguration = TanyaAIConfiguration(),
        dependencies: TanyaAIDependencies,
        onClose: @escaping () -> Void = {}
    ) -> TanyaAIRootView {
        let dependencyContainer = TanyaAIDependencyContainer(
            configuration: configuration,
            dependencies: dependencies
        )
        return TanyaAIRootView(
            dependencyContainer: dependencyContainer,
            closeHandler: onClose
        )
    }
}
