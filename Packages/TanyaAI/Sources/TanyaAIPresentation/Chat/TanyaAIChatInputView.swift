import SwiftUI

/// The composer.
///
/// A single capsule holds the field, and the action sits in a filled circle
/// beside it: sending and stopping occupy the same place, so the control the
/// customer reaches for never moves.
struct TanyaAIChatInputView: View {
    @ObservedObject var viewModel: TanyaAIChatViewModel
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            field
            actionButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.colors.background)
    }

    private var field: some View {
        TextField("Ask Tanya AI", text: $viewModel.inputText)
            .font(theme.fonts.body)
            .foregroundColor(theme.colors.primaryText)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(theme.colors.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(theme.colors.divider, lineWidth: 1)
            )
            .submitLabel(.send)
            .onSubmit(viewModel.sendCurrentMessage)
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
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(theme.colors.userBubbleText)
                .frame(width: 44, height: 44)
                .background(theme.colors.accent)
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
