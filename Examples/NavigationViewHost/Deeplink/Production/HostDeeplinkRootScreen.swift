import Foundation
import SwiftUI
import TanyaAI

/// The existing `NavigationView` root, wired for the hand-off.
///
/// Two things matter: `fullScreenCover` stays outside the `NavigationView`,
/// and the deeplink is delivered from `onDismiss` rather than straight after
/// the binding flips — at that moment the cover is still animating away.
struct HostDeeplinkRootScreen: View {
    @ObservedObject var presenter: HostTanyaAIPresenter
    @ObservedObject var bridge: HostDeeplinkBridge
    let dependencies: TanyaAIDependencies

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: HostDetailScreen(presenter: presenter)
                ) {
                    Text("Open existing detail")
                }
            }
            .navigationBarTitle("Dashboard")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(
            isPresented: $presenter.isPresented,
            onDismiss: bridge.deliverPendingDeeplink
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
        .onChange(of: bridge.hasPendingDeeplink) { _ in
            deliverIfNothingIsPresented()
        }
    }

    private func deliverIfNothingIsPresented() {
        guard bridge.awaitsDismissal == false else {
            return
        }
        bridge.deliverPendingDeeplink()
    }
}
