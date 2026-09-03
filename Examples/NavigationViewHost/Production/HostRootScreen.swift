import SwiftUI

/// The existing `NavigationView` root, unchanged except for one button.
///
/// Tanya AI is never a `NavigationLink` destination: it is presented as its
/// own controller, so its internal navigation cannot tangle with the legacy
/// stack, and closing it returns the customer exactly where they were.
struct HostRootScreen: View {
    let presenter: HostTanyaAIPresenting

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
