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
        // A deeplink that arrives with nothing presented has no dismissal to
        // wait for. onAppear covers a cold start, onChange covers arrivals
        // while the dashboard is already on screen.
        .onAppear(perform: deliverIfNothingIsPresented)
        .onChange(of: bridge.hasPendingDestination) { _ in
            deliverIfNothingIsPresented()
        }
    }

    private func deliverIfNothingIsPresented() {
        guard bridge.awaitsDismissal == false else {
            return
        }
        deliverPendingDestination()
    }

    /// Runs when the full-screen presentation finished dismissing: return to
    /// the dashboard, then push.
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

    /// A hidden, state-driven link. `NavigationView` has no programmatic push
    /// of its own, so the deeplink destination needs one.
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
            switch destination.type {
            case .transfer:
                ExistingTransferScreen(parameters: destination.parameters)
            case .statement:
                ExistingStatementScreen(parameters: destination.parameters)
            }
        }
    }
}
