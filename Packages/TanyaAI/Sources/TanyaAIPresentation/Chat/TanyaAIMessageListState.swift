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
    /// Empty unless a reply is offering prompts. They render as the last row,
    /// so they sit under the question they answer.
    let suggestions: [TanyaAISuggestion]

    static let empty = TanyaAIMessageListState(
        messages: [],
        isRestoring: false,
        showsTypingRow: false,
        suggestions: []
    )

    var showsSuggestionRow: Bool {
        suggestions.isEmpty == false
    }

    var rowCount: Int {
        messages.count
            + (showsTypingRow ? 1 : 0)
            + (showsSuggestionRow ? 1 : 0)
    }

    /// What each row shows. Messages first, then the waiting row, then the
    /// prompts - the order rows are counted in.
    func kind(at index: Int) -> TanyaAIMessageRowKind? {
        if index < messages.count {
            return .message(messages[index])
        }
        if showsTypingRow, index == messages.count {
            return .typing
        }
        guard showsSuggestionRow, index == rowCount - 1 else {
            return nil
        }
        return .suggestions(suggestions)
    }

    /// Whether the rows themselves differ, as opposed to a message changing
    /// its own contents - which the row observes for itself.
    func rowsDiffer(from other: TanyaAIMessageListState) -> Bool {
        rowCount != other.rowCount
            || messages.map(\.id) != other.messages.map(\.id)
            || suggestions.map(\.id) != other.suggestions.map(\.id)
    }
}

/// What one row in the conversation is.
enum TanyaAIMessageRowKind {
    case message(TanyaAIMessageItemViewModel)
    case typing
    case suggestions([TanyaAISuggestion])
}
