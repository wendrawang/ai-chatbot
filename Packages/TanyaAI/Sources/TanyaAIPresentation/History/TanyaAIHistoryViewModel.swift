import Combine

public final class TanyaAIHistoryViewModel: ObservableObject {
    public struct Item: Identifiable, Equatable {
        public let id: String
        public let title: String
        public let detail: String
    }

    @Published public private(set) var items: [Item]

    public init() {
        items = [
            Item(
                id: "sandbox-history-001",
                title: "Sample portfolio conversation",
                detail: "Local fixture • No customer data"
            )
        ]
    }
}
