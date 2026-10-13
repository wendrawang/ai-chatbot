import Foundation
import TanyaAIDomain

public extension TanyaAIChatViewModel {
    func selectResponseOption(_ messageIdentifier: String, _ groupIdentifier: String, _ choiceIdentifier: String) {
        guard isSendEnabled, let message = message(identifier: messageIdentifier),
            case .response(var payload) = message.content, !payload.isReadOnly,
            let index = payload.blocks.firstIndex(where: {
                if case .options(let options) = $0 { return options.identifier == groupIdentifier }
                return false
            }),
            case .options(var options) = payload.blocks[index], !options.isReadOnly,
            let choice = options.choices.first(where: { $0.identifier == choiceIdentifier }),
            !choice.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }
        options.selectedIdentifier = choiceIdentifier
        options.isReadOnly = true
        payload.blocks[index] = .options(options)
        message.update(content: .response(payload))
        sendMessage(choice.prompt)
    }

    func performResponseAction(_ messageIdentifier: String, _ action: ResponseAction) {
        guard let message = message(identifier: messageIdentifier),
            case .response(let payload) = message.content
        else { return }
        switch action.intent {
        case .prompt:
            guard !payload.isReadOnly else { return }
            sendMessage(action.target)
        case .edit:
            guard !payload.isReadOnly else { return }
            draftRequest = TanyaAIDraftRequest(text: action.target)
        case .destination:
            performInlineLink(action.target, identifier: action.identifier)
        case .authorization:
            authorizeResponse(messageIdentifier, confirmationIdentifier: action.target, title: action.title)
        }
    }

    func performInlineLink(_ target: String, identifier: String = "inline-link") {
        guard let url = URL(string: target), let scheme = url.scheme?.lowercased() else { return }
        let destination: Action.DestinationType = (scheme == "https" || scheme == "http") ? .webview : .deeplink
        onOutput?(.performAction(Action(identifier: identifier, deeplink: target, destinationType: destination)))
    }
}
