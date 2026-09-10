import Foundation

/// What the message table should be showing.
///
/// Grouped rather than passed field by field: the coordinator needs all of it
/// together to decide whether the rows changed, and the parameter list had
/// outgrown what one call should carry.
struct TanyaAIMessageListState {
    let messages: [TanyaAIMessageItemViewModel]
    let isRestoring: Bool
    let showsTypingRow: Bool
    let showsSuggestions: Bool

    static let empty = TanyaAIMessageListState(
        messages: [],
        isRestoring: false,
        showsTypingRow: false,
        showsSuggestions: false
    )

    var rowCount: Int {
        messages.count + (showsTypingRow ? 1 : 0)
    }

    /// Whether the rows themselves differ, as opposed to a message changing
    /// its own contents - which the row observes for itself.
    func rowsDiffer(from other: TanyaAIMessageListState) -> Bool {
        rowCount != other.rowCount
            || messages.map(\.id) != other.messages.map(\.id)
    }
}
