import Foundation
import SwiftUI

struct LegacyRootScreen: View {
    @ObservedObject var tanyaAIPresenter: TanyaAIPresentationGateway
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
        .fullScreenCover(
            isPresented: $tanyaAIPresenter.isPresented,
            onDismiss: deliverPendingDeeplink
        ) {
            tanyaAIPresenter.makeView()
        }
        // A deeplink that arrives with nothing presented has no dismissal to
        // wait for. onAppear covers a cold start, onChange covers arrivals
        // while the dashboard is already on screen.
        .onAppear(perform: deliverPendingDeeplinkIfReady)
        .onChange(of: deeplinkRouter.hasPendingDestination) { _ in
            deliverPendingDeeplinkIfReady()
        }
    }

    private func deliverPendingDeeplinkIfReady() {
        guard deeplinkRouter.awaitsDismissal == false else {
            return
        }
        deliverPendingDeeplink()
    }

    /// A deeplink cannot push while the feature covers the screen, and it must
    /// land on the dashboard first. So: close, pop back to the dashboard, and
    /// only then push the destination.
    ///
    /// `NavigationView` drops a push that starts while a pop is still
    /// animating, so the destination waits for the pop to settle.
    private func deliverPendingDeeplink() {
        guard deeplinkRouter.hasPendingDestination else {
            return
        }
        let isPopping = isDetailActive
        isDetailActive = false
        DispatchQueue.main.asyncAfter(
            deadline: .now() + (isPopping ? Self.popSettlingDelay : 0)
        ) {
            deeplinkRouter.deliverPendingDestination()
        }
    }

    /// Matches the default `NavigationView` pop animation.
    private static let popSettlingDelay: TimeInterval = 0.35

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
