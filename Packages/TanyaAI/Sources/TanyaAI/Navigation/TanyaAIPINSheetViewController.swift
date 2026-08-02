import SwiftUI
import TanyaAIDesignSystem
import TanyaAIPresentation
import UIKit

final class TanyaAIPINSheetViewController: UIViewController {
    private let hostingController: UIHostingController<AnyView>

    init(viewModel: TanyaAIPINViewModel, theme: TanyaAITheme) {
        hostingController = UIHostingController(
            rootView: AnyView(
                TanyaAIPINBottomSheetView(viewModel: viewModel)
                    .tanyaAITheme(theme)
            )
        )
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        view.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        embedHostingController()
    }

    private func embedHostingController() {
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}
