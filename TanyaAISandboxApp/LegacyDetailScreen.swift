import SwiftUI

struct LegacyDetailScreen: View {
    let tanyaAIPresenter: TanyaAIPresenting
    @State private var legacyCounter = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                statusCard
                stateCard
                openTanyaAIButton
                isolationNote
            }
            .padding(20)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("Legacy Detail", displayMode: .inline)
        .accessibilityIdentifier("legacy.detail")
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "link")
                Text("Legacy coordinator active")
            }
            .font(.headline)
            .foregroundColor(.orange)

            Text(
                "This page is still inside the existing " +
                "NavigationView and NavigationLink stack."
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .legacyCardStyle()
    }

    private var stateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Legacy state: \(legacyCounter)")
                .font(.headline)
                .accessibilityIdentifier("legacy.counter")

            Button("Increase legacy state") {
                legacyCounter += 1
            }
            .frame(minHeight: 44)
            .accessibilityIdentifier("legacy.increment")
        }
        .legacyCardStyle()
    }

    private var openTanyaAIButton: some View {
        Button(action: tanyaAIPresenter.presentTanyaAI) {
            HStack {
                Image(systemName: "sparkles")
                Text("Open Tanya AI outside legacy navigation")
                    .font(.headline)
                Spacer()
                Image(systemName: "arrow.up.right.square")
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .frame(minHeight: 54)
            .background(Color.blue)
            .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(
            hint: Text("Presents an independent full-screen UIKit feature")
        )
        .accessibilityIdentifier("legacy.openTanyaAI")
    }

    private var isolationNote: some View {
        Text(
            "Close Tanya AI to return here. The legacy counter and " +
            "navigation position should remain unchanged."
        )
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}

private extension View {
    func legacyCardStyle() -> some View {
        padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(14)
    }
}
