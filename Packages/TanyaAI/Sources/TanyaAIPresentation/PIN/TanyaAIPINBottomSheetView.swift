import SwiftUI

public struct TanyaAIPINBottomSheetView: View {
    @ObservedObject private var viewModel: TanyaAIPINViewModel
    @Environment(\.tanyaAITheme) private var theme

    public init(viewModel: TanyaAIPINViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        sheetContent
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(theme.colors.background)
        .tanyaAIAccessibilityIdentifier("pin.sheet")
    }

    private var sheetContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            TanyaAIPINDigitIndicator(
                enteredDigitCount: viewModel.pin.count
            )
            validationMessage
            authorizationStatus
            TanyaAIPINKeypadView(
                onDigit: viewModel.appendDigit,
                onDelete: viewModel.deleteLastDigit,
                isDisabled: viewModel.isSubmitting
            )

            Text("Sandbox demo PIN: 123456")
                .font(theme.fonts.caption)
                .foregroundColor(theme.colors.secondaryText)
        }
        .padding(20)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Authorize action")
                    .font(theme.fonts.title)
                Text("Enter your 6-digit PIN to continue securely.")
                    .font(theme.fonts.footnote)
                    .foregroundColor(theme.colors.secondaryText)
            }
            Spacer()
            Button(action: viewModel.cancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(theme.fonts.title)
                    .foregroundColor(theme.colors.secondaryText)
                    .frame(width: 44, height: 44)
            }
            .disabled(viewModel.isSubmitting)
            .accessibility(label: Text("Cancel authorization"))
        }
    }

    @ViewBuilder
    private var validationMessage: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(theme.fonts.footnote)
                .foregroundColor(theme.colors.error)
        }
    }

    @ViewBuilder
    private var authorizationStatus: some View {
        if viewModel.isSubmitting {
            HStack(spacing: 8) {
                ProgressView()
                    .tint(theme.colors.accent)
                    .frame(width: 20, height: 20)
                Text("Authorizing securely…")
                    .font(theme.fonts.footnote)
                    .foregroundColor(theme.colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
