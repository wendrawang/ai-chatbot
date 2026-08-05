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
                    .font(theme.fonts.headline)
                Text(item.detail)
                    .font(theme.fonts.subheadline)
                    .foregroundColor(theme.colors.secondaryText)
            }
            .padding(.vertical, 4)
        }
        .listStyle(.plain)
        .background(theme.colors.background)
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
}
