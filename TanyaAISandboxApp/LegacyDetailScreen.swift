import SwiftUI
import TanyaAI

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
        .background(Color.gray.opacity(0.08))
        .navigationBarTitle("Legacy Detail", displayMode: .inline)
        .legacyAccessibilityIdentifier("legacy.detail")
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
                .legacyAccessibilityIdentifier("legacy.counter")

            Button("Increase legacy state") {
                legacyCounter += 1
            }
            .frame(minHeight: 44)
            .legacyAccessibilityIdentifier("legacy.increment")
        }
        .legacyCardStyle()
    }

    /// What this screen already knows, handed to the chat when it opens.
    ///
    /// Only what the customer can already see on this screen - never a token,
    /// a PIN, or a full account number.
    private func openTanyaAI() {
        tanyaAIPresenter.presentTanyaAI(context: chatContext)
    }

    private var chatContext: TanyaAIContext {
        TanyaAIContext(
            screen: "legacy.detail",
            parameters: ["legacyCounter": "\(legacyCounter)"],
            summary: "About: Legacy detail - state \(legacyCounter)"
        )
    }

    private var openTanyaAIButton: some View {
        Button(action: openTanyaAI) {
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
            hint: Text("Presents an independent full-screen SwiftUI feature")
        )
        .legacyAccessibilityIdentifier("legacy.openTanyaAI")
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
            .background(Color.white)
            .cornerRadius(14)
    }
}
