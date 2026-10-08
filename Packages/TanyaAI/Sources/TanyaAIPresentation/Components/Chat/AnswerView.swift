import DesignKit
import SwiftUI
import TanyaAIDomain

/// Supplies bot prompts and host actions to the generic response layout.
struct AnswerView: View {
    let payload: AnswerPayload
    let onSelect: (String) -> Void
    let onAction: (Action) -> Void

    var body: some View {
        ResponseContent(
            text: payload.text,
            options: payload.isAnswered ? [] : payload.options.map {
                SelectionOption(identifier: $0.identifier, title: $0.title)
            },
            image: payload.image,
            onSelect: { onSelect($0.identifier) },
            actions: {
                if let actions = payload.actions, actions.buttons.isEmpty == false {
                    ActionBubble(payload: actions, onAction: onAction)
                }
            }
        )
    }
}
