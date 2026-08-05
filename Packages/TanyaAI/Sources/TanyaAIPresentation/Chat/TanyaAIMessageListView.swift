import SwiftUI

struct TanyaAIMessageListView: View {
    @ObservedObject var viewModel: TanyaAIChatViewModel
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        TanyaAIMessageTableView(
            messages: viewModel.messages,
            isGenerating: viewModel.isGenerating,
            theme: theme,
            onApprovalEdit: viewModel.editApproval,
            onApprovalCancel: viewModel.cancelApproval,
            onApproval: viewModel.approve
        )
    }
}
