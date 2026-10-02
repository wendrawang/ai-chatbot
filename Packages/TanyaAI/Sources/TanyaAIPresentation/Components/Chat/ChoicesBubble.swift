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

    public var body: some View {
        ChoiceGroup(
            title: payload.title,
            options: payload.choices.map { SelectionOption(identifier: $0.identifier, title: $0.title) },
            selected: payload.selected,
            isEnabled: !payload.isSubmitted,
            isSubmittable: payload.isSubmittable,
            submitTitle: payload.submitTitle ?? copy.chat("chat.submit"),
            onToggle: onToggle,
            onSubmit: onSubmit
        )
    }
}
