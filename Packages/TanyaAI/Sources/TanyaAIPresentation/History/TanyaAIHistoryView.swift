import SwiftUI

public struct TanyaAIHistoryView: View {
    @ObservedObject private var viewModel: TanyaAIHistoryViewModel
    @Environment(\.tanyaAITheme) private var theme

    public init(viewModel: TanyaAIHistoryViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List(viewModel.items) { item in
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(Font(theme.fonts.headline))
                Text(item.detail)
                    .font(Font(theme.fonts.subheadline))
                    .foregroundColor(Color(theme.colors.secondaryText))
            }
            .padding(.vertical, 4)
        }
        .listStyle(PlainListStyle())
        .background(Color(theme.colors.background))
        .navigationBarTitle("History", displayMode: .inline)
    }
}
