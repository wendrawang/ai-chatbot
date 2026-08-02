import SwiftUI

struct TanyaAIChatInputView: View {
    @ObservedObject var viewModel: TanyaAIChatViewModel
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Ask Tanya AI", text: $viewModel.inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(Font(theme.fonts.body))

            if viewModel.isGenerating {
                Button(action: viewModel.cancelGeneration) {
                    Image(systemName: "stop.fill")
                        .frame(width: 44, height: 44)
                }
                .accessibility(label: Text("Stop response"))
            } else {
                Button(action: viewModel.sendCurrentMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(Font(theme.fonts.title))
                        .frame(width: 44, height: 44)
                }
                .accessibility(label: Text("Send message"))
            }
        }
        .padding(12)
        .foregroundColor(Color(theme.colors.accent))
    }
}
