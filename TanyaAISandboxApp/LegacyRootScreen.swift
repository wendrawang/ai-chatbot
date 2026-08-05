import SwiftUI

struct LegacyRootScreen: View {
    @ObservedObject var tanyaAIPresenter: TanyaAIPresentationGateway

    var body: some View {
        NavigationView {
            List {
                introductionSection
                navigationSection
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Legacy Home")
            .legacyAccessibilityIdentifier("legacy.home")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(
            isPresented: $tanyaAIPresenter.isPresented
        ) {
            tanyaAIPresenter.makeView()
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
                )
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
