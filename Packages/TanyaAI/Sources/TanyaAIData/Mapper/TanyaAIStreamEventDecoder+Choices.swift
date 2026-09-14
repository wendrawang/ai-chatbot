import DesignKit
import Foundation
import TanyaAIDomain

/// The two cards a customer looks at rather than reads: a question with
/// chips to answer it, and a picture with its caption.
extension TanyaAIStreamEventDecoder {
    func decodeChoices(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIChoicesDTO.self, from: data)
        let choices = payload.choices.map {
            ChoicesPayload.Choice(
                identifier: $0.identifier,
                title: $0.title,
                // A choice with no prompt sends its own label. Most questions
                // need no second wording, and requiring one invites copies of
                // the same string.
                prompt: $0.prompt ?? $0.title
            )
        }
        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: .choices(
                ChoicesPayload(
                    identifier: payload.messageIdentifier,
                    title: payload.title,
                    choices: choices,
                    allowsMultipleSelection:
                        payload.allowsMultipleSelection ?? true,
                    submitTitle: payload.submitTitle ?? "Submit"
                )
            )
        )
    }

    func decodeImage(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIImageDTO.self, from: data)
        // An unusable url degrades to the caption alone rather than throwing:
        // the sentence is the message, and losing the whole bubble over a
        // broken link would lose more than the picture.
        let image = ImagePayload(
            imageURL: URL(string: payload.imageURL),
            caption: payload.caption,
            aspectRatio: payload.aspectRatio
                ?? ImagePayload.defaultAspectRatio,
            accessibilityText: payload.accessibilityText
        )
        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: .image(image)
        )
    }
}
