import SwiftUI
import TanyaAI

/// The existing `NavigationView` root, unchanged except for one modifier.
///
/// `fullScreenCover` sits on the `NavigationView`, not inside it, and Tanya AI
/// is never a `NavigationLink` destination. That keeps the feature's own
/// `NavigationStack` out of the legacy hierarchy and keeps the presentation
/// alive across pushes and pops.
struct HostRootScreen: View {
    @ObservedObject var presenter: HostTanyaAIPresenter
    let composition: HostTanyaAIComposition

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Existing menu")) {
                    NavigationLink(
                        destination: HostDetailScreen(presenter: presenter)
                    ) {
                        Text("Open existing detail")
                    }
                }
            }
            .navigationBarTitle("Home")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $presenter.isPresented) {
            TanyaAIModule.makeView(
                configuration: composition.configuration,
                dependencies: composition.dependencies,
                onClose: presenter.dismissTanyaAI
            )
        }
    }
}

/// A pushed screen deep inside the legacy stack.
///
/// It triggers the feature through the presenter, so its own navigation
/// position and local state survive open and close.
struct HostDetailScreen: View {
    let presenter: HostTanyaAIPresenting
    @State private var counter = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Local state: \(counter)")
            Button("Increase local state") {
                counter += 1
            }
            Button("Open Tanya AI", action: presenter.presentTanyaAI)
            Spacer()
        }
        .padding(20)
        .navigationBarTitle("Detail", displayMode: .inline)
    }
}
