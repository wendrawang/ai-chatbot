import Foundation

/// Radio options send on touch. Explicit multi-selection requires confirmation.
public struct ChoicesPayload: Equatable {
    public struct Choice: Equatable {
        public let identifier: String
        public let title: String
        /// What is sent when this choice is part of the answer. Separate from
        /// `title` so a chip can read "Dining" while the bot receives
        /// something it can actually parse.
        public let prompt: String

        public init(identifier: String, title: String, prompt: String) {
            self.identifier = identifier
            self.title = title
            self.prompt = prompt
        }
    }

    /// The bubble's own identity, so a selection can find its way back to the
    /// right card when the same question is asked twice.
    public let identifier: String
    public let title: String?
    public let choices: [Choice]
    /// False makes each tap replace the selection instead of adding to it.
    public let isMultipleSelectionAllowed: Bool
    public let submitTitle: String?
    public var selected: Set<String>
    /// Answered radio options disappear; the question text remains.
    public var isSubmitted: Bool

    public var isSubmittable: Bool {
        isSubmitted == false && selected.isEmpty == false
    }

    /// What the customer's turn says, in the order the choices were offered
    /// rather than the order they were tapped.
    public var answerPrompt: String {
        choices
            .filter { selected.contains($0.identifier) }
            .map(\.prompt)
            .joined(separator: ", ")
    }

    public init(
        identifier: String,
        title: String?,
        choices: [Choice],
        isMultipleSelectionAllowed: Bool = false,
        submitTitle: String? = nil,
        selected: Set<String> = [],
        isSubmitted: Bool = false
    ) {
        self.identifier = identifier
        self.title = title
        self.choices = choices
        self.isMultipleSelectionAllowed = isMultipleSelectionAllowed
        self.submitTitle = submitTitle
        self.selected = selected
        self.isSubmitted = isSubmitted
    }

    /// Applies a tap. Single-select replaces, multi-select toggles.
    public func toggling(_ identifier: String) -> ChoicesPayload {
        var copy = self
        guard isMultipleSelectionAllowed else {
            copy.selected = selected.contains(identifier) ? [] : [identifier]
            return copy
        }
        if copy.selected.contains(identifier) {
            copy.selected.remove(identifier)
        } else {
            copy.selected.insert(identifier)
        }
        return copy
    }
}
