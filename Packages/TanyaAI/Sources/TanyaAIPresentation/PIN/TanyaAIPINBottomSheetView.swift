import SwiftUI

public struct TanyaAIPINBottomSheetView: View {
    @ObservedObject private var viewModel: TanyaAIPINViewModel
    @Environment(\.tanyaAITheme) private var theme

    public init(viewModel: TanyaAIPINViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color(theme.colors.overlay)
                .edgesIgnoringSafeArea(.all)

            sheetContent
                .background(Color(theme.colors.background))
                .cornerRadius(20, corners: [.topLeft, .topRight])
        }
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
                .font(Font(theme.fonts.caption))
                .foregroundColor(Color(theme.colors.secondaryText))
        }
        .padding(20)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Authorize action")
                    .font(Font(theme.fonts.title))
                Text("Enter your 6-digit PIN to continue securely.")
                    .font(Font(theme.fonts.footnote))
                    .foregroundColor(Color(theme.colors.secondaryText))
            }
            Spacer()
            Button(action: viewModel.cancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(Font(theme.fonts.title))
                    .foregroundColor(Color(theme.colors.secondaryText))
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
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.error))
        }
    }

    @ViewBuilder
    private var authorizationStatus: some View {
        if viewModel.isSubmitting {
            HStack(spacing: 8) {
                TanyaAIPINActivityIndicator(color: theme.colors.accent)
                    .frame(width: 20, height: 20)
                Text("Authorizing securely…")
                    .font(Font(theme.fonts.footnote))
                    .foregroundColor(Color(theme.colors.secondaryText))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct TanyaAIPINActivityIndicator: UIViewRepresentable {
    let color: UIColor

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = color
        indicator.startAnimating()
        return indicator
    }

    func updateUIView(
        _ indicator: UIActivityIndicatorView,
        context: Context
    ) {
        indicator.color = color
    }
}

private struct TanyaAIRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rectangle: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rectangle,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(TanyaAIRoundedCorner(radius: radius, corners: corners))
    }
}
