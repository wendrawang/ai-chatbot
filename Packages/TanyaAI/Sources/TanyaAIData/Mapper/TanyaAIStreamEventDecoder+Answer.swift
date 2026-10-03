import DesignKit
import Foundation
import TanyaAIDomain

extension TanyaAIStreamEventDecoder {
    func decodeAnswer(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIAnswerDTO.self, from: data)
        let options = (payload.options ?? []).map {
            Suggestion(identifier: $0.identifier, title: $0.title, prompt: $0.prompt ?? $0.title)
        }
        let buttons = (payload.actions ?? []).map(makeActionButton)
        let answer = AnswerPayload(
            text: payload.text,
            options: options,
            image: payload.image.map(makeAnswerImage),
            actions: buttons.isEmpty ? nil : ActionPayload(buttons: buttons),
            isAnswered: payload.isAnswered ?? false
        )
        let isEmpty = (answer.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && options.isEmpty && answer.image == nil && buttons.isEmpty
        return .content(
            messageIdentifier: payload.messageIdentifier,
            content: isEmpty ? .unsupported(nil) : .answer(answer)
        )
    }

    private func makeAnswerImage(_ image: TanyaAIAnswerImageDTO) -> ImagePayload {
        ImagePayload(
            imageURL: URL(string: image.imageURL),
            caption: image.caption ?? "",
            aspectRatio: image.aspectRatio ?? ImagePayload.defaultAspectRatio,
            accessibilityText: image.accessibilityText
        )
    }
}
