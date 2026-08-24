import Foundation
import SwiftUI
import TanyaAI

/// The existing `NavigationView` root, wired for the hand-off.
///
/// Three things matter here: `fullScreenCover` stays outside the
/// `NavigationView`, the destination is delivered from `onDismiss`, and the
/// legacy detail screen is popped before the destination is pushed.
struct HostDeeplinkRootScreen: View {
    @ObservedObject var presenter: HostTanyaAIPresenter
    @ObservedObject var bridge: HostDeeplinkBridge
    let dependencies: TanyaAIDependencies

    @State private var isDetailActive = false

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: HostDetailScreen(presenter: presenter),
                    isActive: $isDetailActive
                ) {
                    Text("Open existing detail")
                }
            }
            .navigationBarTitle("Dashboard")
            .background(destinationLink)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(
            isPresented: $presenter.isPresented,
            onDismiss: deliverPendingDestination
        ) {
            TanyaAIModule.makeView(
                dependencies: dependencies,
                onClose: presenter.dismissTanyaAI,
                onAction: { [weak bridge] action in
                    bridge?.handle(action)
                }
            )
        }
    }

    private func deliverPendingDestination() {
        guard bridge.hasPendingDestination else {
            return
        }
        // Back to the dashboard first…
        let isPopping = isDetailActive
        isDetailActive = false
        // …then push, once the pop has settled. NavigationView drops a push
        // that starts while a pop is still animating.
        DispatchQueue.main.asyncAfter(
            deadline: .now() + (isPopping ? 0.35 : 0)
        ) {
            bridge.deliverPendingDestination()
        }
    }

    private var destinationLink: some View {
        NavigationLink(
            destination: destinationScreen,
            isActive: Binding(
                get: { bridge.activeDestination != nil },
                set: { isActive in
                    if isActive == false {
                        bridge.clearDestination()
                    }
                }
            ),
            label: { EmptyView() }
        )
        .hidden()
    }

    @ViewBuilder
    private var destinationScreen: some View {
        if let destination = bridge.activeDestination {
            switch destination.route {
            case .transferForm:
                ExistingTransferScreen(parameters: destination.parameters)
            case .statementDetail:
                ExistingStatementScreen(parameters: destination.parameters)
            }
        }
    }
}
