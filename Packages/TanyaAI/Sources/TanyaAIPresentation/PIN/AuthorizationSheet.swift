import DesignKit
import SwiftUI

public struct AuthorizationSheet: View {

    @Environment(\.copyCatalog) private var copy
    @ObservedObject private var viewModel: TanyaAIPINViewModel
    @Environment(\.theme) private var theme

    public init(viewModel: TanyaAIPINViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color(theme.colors.overlay)
                .edgesIgnoringSafeArea(.all)

            sheetContent
                .background(Color(theme.colors.background))
                .clipShape(RoundedCorners(radius: DesignKitMetrics.Radius.sheet.sizeInArtwork,
                                          corners: [.topLeft, .topRight]))
        }
        .accessibilityIdentifier("pin.sheet")
    }

    private var sheetContent: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing16.sizeInArtwork) {
            header
            SecureCodeIndicator(
                enteredDigitCount: viewModel.pin.count,
                totalDigitCount: TanyaAIPINViewModel.requiredDigitCount,
                label: copy.chat("chat.pinProgress", values: [
                    "count": String(viewModel.pin.count), "total": String(TanyaAIPINViewModel.requiredDigitCount)
                ])
            )
            validationMessage
            authorizationStatus
            NumericKeypad(
                onDigit: viewModel.appendDigit,
                onDelete: viewModel.deleteLastDigit,
                isDisabled: viewModel.isSubmitting
            )

        }
        .padding(DesignKitMetrics.Spacing.large.sizeInArtwork)
    }

    private var header: some View {
        HStack(spacing: FigmaSize.spacing8.sizeInArtwork) {
            VStack(alignment: .leading, spacing: FigmaSize.spacing4.sizeInArtwork) {
                Text(copy.chat("chat.authorizeTitle"))
                    .font(Font(theme.fonts.title))
                Text(copy.chat("chat.pinInstruction", values: [
                    "count": String(TanyaAIPINViewModel.requiredDigitCount)
                ]))
                    .font(Font(theme.fonts.footnote))
                    .foregroundColor(Color(theme.colors.secondaryText))
            }
            Spacer(minLength: FigmaSize.spacing8.sizeInArtwork)
            Button(action: viewModel.cancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(Font(theme.fonts.title))
                    .foregroundColor(Color(theme.colors.secondaryText))
                    .frame(
                        width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                        height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                    )
            }
            .disabled(viewModel.isSubmitting)
            .accessibility(label: Text(copy.chat("chat.cancelAuthorization")))
        }
    }

    @ViewBuilder
    private var validationMessage: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.error))
        }
    }

    @ViewBuilder
    private var authorizationStatus: some View {
        if viewModel.isSubmitting {
            HStack(spacing: FigmaSize.spacing8.sizeInArtwork) {
                ProgressView().tint(Color(theme.colors.accent))
                    .frame(width: DesignKitMetrics.Size.indicator.sizeInArtwork,
                           height: DesignKitMetrics.Size.indicator.sizeInArtwork)
                Text(copy.chat("chat.authorizing"))
                    .font(Font(theme.fonts.footnote))
                    .foregroundColor(Color(theme.colors.secondaryText))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
