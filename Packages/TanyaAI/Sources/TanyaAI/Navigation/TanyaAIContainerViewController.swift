import TanyaAIDomain
import UIKit

final class TanyaAIContainerViewController: UIViewController {
    private let featureNavigationController = UINavigationController()
    private var coordinator: TanyaAICoordinator?
    private let dependencyContainer: TanyaAIDependencyContainer
    private let actionHandler: (TanyaAIAction) -> Void

    init(
        dependencyContainer: TanyaAIDependencyContainer,
        actionHandler: @escaping (TanyaAIAction) -> Void = { _ in }
    ) {
        self.dependencyContainer = dependencyContainer
        self.actionHandler = actionHandler
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        embedNavigationController()
        startCoordinator()
    }

    private func embedNavigationController() {
        addChild(featureNavigationController)
        view.addSubview(featureNavigationController.view)
        featureNavigationController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            featureNavigationController.view.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            featureNavigationController.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            featureNavigationController.view.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            featureNavigationController.view.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
        featureNavigationController.didMove(toParent: self)
    }

    private func startCoordinator() {
        let coordinator = TanyaAICoordinator(
            navigationController: featureNavigationController,
            dependencyContainer: dependencyContainer,
            containerController: self,
            actionHandler: actionHandler
        )
        self.coordinator = coordinator
        coordinator.start()
    }
}
