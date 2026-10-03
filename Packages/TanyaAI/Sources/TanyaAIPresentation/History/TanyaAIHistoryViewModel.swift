import Combine
import TanyaAIDomain

public final class TanyaAIHistoryViewModel: ObservableObject {
    public typealias Item = ConversationSummary
    @Published public private(set) var items: [Item]

    public init(items: [Item] = []) {
        self.items = items
    }
}
