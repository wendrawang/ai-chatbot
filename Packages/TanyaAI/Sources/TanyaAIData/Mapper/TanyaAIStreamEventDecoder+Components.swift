import DesignKit
import Foundation
import TanyaAIDomain

extension TanyaAIStreamEventDecoder {
    /// The custom JSON vocabulary is independent of the SDK carrying it.
    func decodeComponents(_ data: Data) throws -> TanyaAIStreamEvent {
        let payload = try decoder.decode(TanyaAIComponentsDTO.self, from: data)
        guard !payload.elements.isEmpty, payload.elements.count <= 64 else { throw CocoaError(.coderReadCorrupt) }
        let content = try componentContent(payload.elements)
        return .content(messageIdentifier: payload.messageIdentifier, content: content)
    }

    private func componentContent(_ parts: [TanyaAIComponentDTO]) throws -> TanyaAIMessageContent {
        if let content = try confirmationContent(parts) { return content }
        var texts: [String] = []
        var options: [Suggestion] = []
        var image: ImagePayload?
        var buttons: [ActionButton] = []
        for (index, part) in parts.enumerated() {
            switch part.type {
            case "text":
                guard let text = part.text else { throw CocoaError(.coderReadCorrupt) }
                texts.append(text)
            case "radio_button":
                guard options.isEmpty else { throw CocoaError(.coderReadCorrupt) }
                options = try radioOptions(part)
            case "info_card":
                guard image == nil else { throw CocoaError(.coderReadCorrupt) }
                image = try informationImage(part)
            case "link_button":
                buttons.append(try linkButton(part, index: index))
            default: throw CocoaError(.coderReadCorrupt)
            }
        }
        return assembledContent(texts: texts, options: options, image: image, buttons: buttons)
    }

    private func assembledContent(
        texts: [String], options: [Suggestion], image: ImagePayload?, buttons: [ActionButton]
    ) -> TanyaAIMessageContent {
        let text = texts.isEmpty ? nil : texts.joined(separator: "\n")
        if options.isEmpty, image == nil, buttons.isEmpty { return .text(text ?? "") }
        return .answer(AnswerPayload(
            text: text, options: options, image: image,
            actions: buttons.isEmpty ? nil : ActionPayload(buttons: buttons)
        ))
    }

    private func confirmationContent(_ parts: [TanyaAIComponentDTO]) throws -> TanyaAIMessageContent? {
        if let confirmation = parts.first?.confirmation {
            guard parts.count == 1, !confirmation.confirmationIdentifier.isEmpty,
                  !confirmation.fields.isEmpty,
                  Set(confirmation.fields.map(\.key)).count == confirmation.fields.count else {
                throw CocoaError(.coderReadCorrupt)
            }
            return .confirmation(confirmation)
        }
        return nil
    }

    private func radioOptions(_ part: TanyaAIComponentDTO) throws -> [Suggestion] {
        guard let options = part.options, !options.isEmpty,
              Set(options.map(\.value)).count == options.count,
              options.allSatisfy({ !$0.value.isEmpty && !$0.label.isEmpty }) else {
            throw CocoaError(.coderReadCorrupt)
        }
        // The label is the visible customer prompt; value is its protocol identifier.
        return options.map { Suggestion(identifier: $0.value, title: $0.label, prompt: $0.label) }
    }

    private func informationImage(_ part: TanyaAIComponentDTO) throws -> ImagePayload {
        guard let title = part.title, let description = part.description else { throw CocoaError(.coderReadCorrupt) }
        return ImagePayload(imageURL: part.image.flatMap(URL.init(string:)), caption: description, title: title)
    }

    private func linkButton(_ part: TanyaAIComponentDTO, index: Int) throws -> ActionButton {
        guard let label = part.label, !label.isEmpty, let target = part.target, !target.isEmpty,
              let destination = part.destinationType else { throw CocoaError(.coderReadCorrupt) }
        return ActionButton(title: label, action: Action(
            identifier: "link-\(index)", deeplink: target, destinationType: destination
        ))
    }
}
