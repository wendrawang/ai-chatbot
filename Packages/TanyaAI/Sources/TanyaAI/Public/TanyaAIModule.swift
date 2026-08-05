import UIKit

public enum TanyaAIModule {
    public static func makeViewController(
        configuration: TanyaAIConfiguration = TanyaAIConfiguration(),
        dependencies: TanyaAIDependencies
    ) -> UIViewController {
        let dependencyContainer = TanyaAIDependencyContainer(
            configuration: configuration,
            dependencies: dependencies
        )
        return TanyaAIContainerViewController(
            dependencyContainer: dependencyContainer
        )
    }
}
