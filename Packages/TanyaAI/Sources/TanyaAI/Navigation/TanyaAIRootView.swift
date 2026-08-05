import SwiftUI
import TanyaAIDesignSystem
import TanyaAIPresentation

public struct TanyaAIRootView: View {
    @StateObject private var router: TanyaAIRouter
    private let theme: TanyaAITheme

    init(
        dependencyContainer: TanyaAIDependencyContainer,
        closeHandler: @escaping () -> Void
    ) {
        theme = dependencyContainer.theme
        _router = StateObject(
            wrappedValue: TanyaAIRouter(
                dependencyContainer: dependencyContainer,
                closeHandler: closeHandler
            )
        )
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            TanyaAIChatView(viewModel: router.chatViewModel)
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: TanyaAIRoute.self) { route in
                    destination(for: route)
                }
        }
        .sheet(
            item: $router.authorizationSheet,
            onDismiss: router.authorizationSheetDidDismiss
        ) { sheet in
            TanyaAIAuthorizationSheetView(
                viewModel: sheet.viewModel
            )
        }
        .tanyaAITheme(theme)
        .onAppear(perform: router.startIfNeeded)
    }

    @ViewBuilder
    private func destination(for route: TanyaAIRoute) -> some View {
        switch route {
        case .history:
            TanyaAIHistoryView(viewModel: router.historyViewModel)
        }
    }
}

private struct TanyaAIAuthorizationSheetView: View {
    @ObservedObject var viewModel: TanyaAIPINViewModel

    var body: some View {
        TanyaAIPINBottomSheetView(viewModel: viewModel)
            .presentationDetents([.fraction(0.78)])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(viewModel.isSubmitting)
    }
}
