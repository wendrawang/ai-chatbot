import DesignKit
import SwiftUI
import TanyaAIDomain

public struct ConversationHistoryScreen: View {
    @Environment(\.copyCatalog) private var copy
    private let items: [ConversationSummary]
    @Environment(\.theme) private var theme

    public init(items: [ConversationSummary]) {
        self.items = items
    }

    public var body: some View {
        List(items, id: \.identifier) { item in
            SummaryRow(title: item.title, detail: item.detail)
        }
        .listStyle(.plain)
        .overlay {
            if items.isEmpty {
                Text(copy.chat("chat.emptyHistory"))
                    .designFont(.body)
                    .foregroundColor(Color(theme.colors.secondaryText))
            }
        }
        .background(Color(theme.colors.background))
        .navigationBarTitle(copy.chat("chat.history"), displayMode: .inline)
    }
}
