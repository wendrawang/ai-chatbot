import SwiftUI
import TanyaAI

/// A host coordinator screen with Tanya AI attached.
///
/// Shaped like the coordinator most applications already have: a
/// `NavigationView` root that appears well after launch, owning its own
/// ViewModel and navigation state.
///
/// What is worth noticing is what the screen does *not* hold. There is no
/// `isShowTanyaAI` flag and no `pendingDeeplink`, because neither is view
/// state: whether the feature is on screen belongs to the presenter, and the
/// hand-off's ordering is the dismissal completion rather than a second piece
/// of state the screen has to keep in step.
struct HostSwiftUICoordinator: View {
    /// Created by whoever creates this screen - see
    /// `HostSwiftUICoordinatorFactory` - so it outlives a redraw.
    let presenter: HostTanyaAIPresenter

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Existing application")) {
                    NavigationLink(destination: Text("An existing screen")) {
                        Text("Open an existing screen")
                    }
                }
                Section(header: Text("Assistant")) {
                    Button("Ask Tanya AI", action: presenter.presentTanyaAI)
                }
            }
            .navigationBarTitle("Dashboard")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tanyaAIHost(presenter)
    }
}

/// Builds the screen and the two objects behind it.
///
/// Both are created once, here, and held by the caller. Creating them inside
/// the `View` would rebuild them on every redraw and lose the presentation
/// mid-flight; if the screen must own them instead, hold them in a
/// `@StateObject` wrapper rather than in `@State`.
enum HostSwiftUICoordinatorFactory {
    /// - Parameters:
    ///   - dependencies: the host's transport, authorization service, theme.
    ///   - dispatch: the app's existing deeplink handler - the same function
    ///     `scene(_:openURLContexts:)` already calls.
    static func make(
        dependencies: TanyaAIDependencies,
        dispatch: @escaping (URL) -> Void
    ) -> (view: HostSwiftUICoordinator, bridge: HostDeeplinkBridge) {
        let presenter = HostTanyaAIPresenter(dependencies: dependencies)
        let bridge = HostDeeplinkBridge(
            presenter: presenter,
            dispatch: dispatch
        )
        // The feature reports a deeplink; the bridge decides what happens.
        presenter.onAction { [weak bridge] action in
            bridge?.handle(action)
        }
        return (HostSwiftUICoordinator(presenter: presenter), bridge)
    }
}
