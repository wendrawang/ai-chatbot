import DesignKit
import Foundation
import TanyaAIDomain

/// What the message table should be showing.
///
/// Grouped rather than passed field by field: the coordinator needs all of it
/// together to decide whether the rows changed, and the parameter list had
/// outgrown what one call should carry.
struct TanyaAIMessageListState {
    let messages: [TanyaAIMessageItemViewModel]
    let isRestoring: Bool
    let isTypingRowVisible: Bool
    /// Empty unless a reply is offering prompts. They render as the last row,
    /// so they sit under the question they answer.
    let suggestions: [Suggestion]
    /// The question those prompts answer, when the reply sent one.
    let suggestionsTitle: String?
    var timestamp: String?
    var latestPromptIdentifier: String?

    static let empty = TanyaAIMessageListState(
        messages: [],
        isRestoring: false,
        isTypingRowVisible: false,
        suggestions: [],
        suggestionsTitle: nil
    )

    var isSuggestionRowVisible: Bool {
        suggestions.isEmpty == false
    }

    var rowCount: Int {
        messages.count
            + (timestamp == nil ? 0 : 1)
            + (isTypingRowVisible ? 1 : 0)
            + (isSuggestionRowVisible ? 1 : 0)
    }

    /// What each row shows. Messages first, then the waiting row, then the
    /// prompts - the order rows are counted in.
    func kind(at index: Int) -> TanyaAIMessageRowKind? {
        guard index >= 0 else { return nil }
        let offset = timestamp == nil ? 0 : 1
        if index == 0, let timestamp { return .timestamp(timestamp) }
        let position = index - offset
        if position >= 0, position < messages.count {
            return .message(messages[position])
        }
        if isTypingRowVisible, position == messages.count {
            return .typing
        }
        guard isSuggestionRowVisible, index == rowCount - 1 else {
            return nil
        }
        return .suggestions(title: suggestionsTitle, items: suggestions)
    }

    /// Whether the rows themselves differ, as opposed to a message changing
    /// its own contents - which the row observes for itself.
    func rowsDiffer(from other: TanyaAIMessageListState) -> Bool {
        timestamp != other.timestamp || isTypingRowVisible != other.isTypingRowVisible
            || !messages.elementsEqual(other.messages, by: { $0 === $1 })
            || suggestions != other.suggestions
            || suggestionsTitle != other.suggestionsTitle
    }

    func rowIndex(messageIdentifier: String) -> Int? {
        messages.firstIndex(where: { $0.identifier == messageIdentifier }).map { $0 + (timestamp == nil ? 0 : 1) }
    }
}

/// What one row in the conversation is.
enum TanyaAIMessageRowKind {
    case message(TanyaAIMessageItemViewModel)
    case typing
    case suggestions(title: String?, items: [Suggestion])
    case timestamp(String)
}
