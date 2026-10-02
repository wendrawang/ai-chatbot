import DesignKit
import SwiftUI

/// The composer.
///
/// A single capsule holds the field, and the action sits in a filled circle
/// beside it: sending and stopping occupy the same place, so the control the
/// customer reaches for never moves.
struct TanyaAIChatInputView: View {
    @ObservedObject var viewModel: TanyaAIChatViewModel
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    var body: some View {
        HStack(alignment: .bottom, spacing: artwork.size(10)) {
            field
            actionButton
        }
        .padding(.horizontal, artwork.size(16))
        .padding(.vertical, artwork.size(12))
        .background(Color(theme.colors.background))
    }

    private var field: some View {
        ZStack(alignment: .topLeading) {
            TanyaAIGrowingTextView(
                text: $viewModel.inputText,
                font: theme.fonts.body,
                textColor: theme.colors.primaryText
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)

            if viewModel.inputText.isEmpty {
                Text("Ask Tanya AI")
                    .font(Font(theme.fonts.body))
                    .foregroundColor(Color(theme.colors.secondaryText))
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
        }
        .padding(.horizontal, artwork.size(18))
        .padding(.vertical, artwork.size(12))
        .background(Color(theme.colors.surface))
        .clipShape(RoundedRectangle(cornerRadius: artwork.size(22)))
        .overlay(
            RoundedRectangle(cornerRadius: artwork.size(22))
                .stroke(Color(theme.colors.divider), lineWidth: artwork.size(1))
        )
    }

    @ViewBuilder
    private var actionButton: some View {
        if viewModel.isGenerating {
            circularButton(
                symbol: "stop.fill",
                label: "Stop response",
                action: viewModel.cancelGeneration
            )
        } else {
            circularButton(
                symbol: "arrow.up",
                label: "Send message",
                action: viewModel.sendCurrentMessage
            )
            .opacity(isSendEnabled ? 1 : 0.4)
            .disabled(isSendEnabled == false)
        }
    }

    private func circularButton(
        symbol: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: artwork.size(16), weight: .bold))
                .foregroundColor(Color(theme.colors.userBubbleText))
                .frame(width: artwork.tapTarget(), height: artwork.tapTarget())
                .background(Color(theme.colors.accent))
                .clipShape(Circle())
        }
        .accessibility(label: Text(label))
    }

    private var isSendEnabled: Bool {
        viewModel.inputText.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty == false
    }
}
