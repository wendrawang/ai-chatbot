import SwiftUI

struct LegacyRootScreen: View {
    let tanyaAIPresenter: TanyaAIPresenting
    @ObservedObject var deeplinkRouter: SandboxDeeplinkRouter

    @State private var isDetailActive = false

    var body: some View {
        NavigationView {
            List {
                introductionSection
                navigationSection
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Legacy Home")
            .legacyAccessibilityIdentifier("legacy.home")
            .background(deeplinkTargetLink)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onChange(of: deeplinkRouter.activeDestination) { destination in
            // A deeplink lands on the dashboard first: pop whatever the
            // customer had pushed before the destination appears.
            if destination != nil {
                isDetailActive = false
            }
        }
    }

    /// `NavigationView` has no programmatic push of its own, so the deeplink
    /// destination needs a hidden, state-driven link.
    private var deeplinkTargetLink: some View {
        NavigationLink(
            destination: deeplinkDestination,
            isActive: Binding(
                get: { deeplinkRouter.activeDestination != nil },
                set: { isActive in
                    if isActive == false {
                        deeplinkRouter.clearDestination()
                    }
                }
            ),
            label: { EmptyView() }
        )
        .hidden()
    }

    @ViewBuilder
    private var deeplinkDestination: some View {
        if let destination = deeplinkRouter.activeDestination {
            SandboxDeeplinkTargetScreen(destination: destination)
        }
    }

    private var introductionSection: some View {
        Section(header: Text("Existing application")) {
            VStack(alignment: .leading, spacing: 8) {
                Text("NavigationView Sandbox")
                    .font(.headline)
                Text(
                    "This screen represents the existing coordinator " +
                    "and NavigationLink hierarchy."
                )
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }

    private var navigationSection: some View {
        Section(header: Text("Legacy destination")) {
            NavigationLink(
                destination: LegacyDetailScreen(
                    tanyaAIPresenter: tanyaAIPresenter
                ),
                isActive: $isDetailActive
            ) {
                HStack(spacing: 12) {
                    Image(systemName: "building.columns")
                        .foregroundColor(.orange)
                    Text("Open legacy detail")
                }
            }
            .legacyAccessibilityIdentifier("legacy.openDetail")
        }
    }
}

extension View {
    @ViewBuilder
    func legacyAccessibilityIdentifier(_ identifier: String) -> some View {
        if #available(iOS 14.0, *) {
            accessibilityIdentifier(identifier)
        } else {
            self
        }
    }
}
