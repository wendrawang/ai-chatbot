import DesignKit
import SwiftUI
import TanyaAIDomain

/// Adapts feature selection rules and backend prompts to the reusable layout.
public struct ChoicesBubble: View {
    private let payload: ChoicesPayload
    private let onToggle: (String) -> Void
    private let onSubmit: () -> Void
    @Environment(\.copyCatalog) private var copy

    public init(payload: ChoicesPayload, onToggle: @escaping (String) -> Void, onSubmit: @escaping () -> Void) {
        self.payload = payload
        self.onToggle = onToggle
        self.onSubmit = onSubmit
    }

    @ViewBuilder public var body: some View {
        if payload.isMultipleSelectionAllowed {
            multipleChoices
        } else {
            ResponseContent(
                text: payload.title,
                options: payload.isSubmitted ? [] : options,
                onSelect: { onToggle($0.identifier) },
                actions: { }
            )
        }
    }

    private var options: [SelectionOption] {
        payload.choices.map { SelectionOption(identifier: $0.identifier, title: $0.title) }
    }

    private var multipleChoices: some View {
        ChoiceGroup(
            title: payload.title,
            options: options,
            selected: payload.selected,
            isEnabled: !payload.isSubmitted,
            isSubmittable: payload.isSubmittable,
            submitTitle: payload.submitTitle ?? copy.chat("chat.submit"),
            onToggle: onToggle,
            onSubmit: onSubmit
        )
    }
}
