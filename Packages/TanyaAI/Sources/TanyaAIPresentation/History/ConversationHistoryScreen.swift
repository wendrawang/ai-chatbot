import DesignKit
import SwiftUI

public struct ConversationHistoryScreen: View {
    @Environment(\.copyCatalog) private var copy
    @ObservedObject private var viewModel: TanyaAIHistoryViewModel
    @Environment(\.theme) private var theme

    public init(viewModel: TanyaAIHistoryViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List(viewModel.items, id: \.identifier) { item in
            SummaryRow(title: item.title, detail: item.detail)
        }
        .listStyle(PlainListStyle())
        .overlay {
            if viewModel.items.isEmpty {
                Text(copy.chat("chat.emptyHistory"))
                    .designFont(.body)
                    .foregroundColor(Color(theme.colors.secondaryText))
            }
        }
        .background(Color(theme.colors.background))
        .navigationBarTitle(copy.chat("chat.history"), displayMode: .inline)
    }
}
