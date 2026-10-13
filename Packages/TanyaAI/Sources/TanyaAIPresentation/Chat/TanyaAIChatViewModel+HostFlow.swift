import Foundation
import TanyaAIContracts
import TanyaAIDomain

struct PendingHostFlow {
    let request: TanyaAIHostFlowRequest
    let messageIdentifier: String
    let confirmationIdentifier: String
}

public extension TanyaAIChatViewModel {
    func openResponseDocument(
        _ messageIdentifier: String, _ confirmationIdentifier: String, _ documentIdentifier: String
    ) {
        guard isHostFlowEnabled, pendingHostFlow == nil,
            let documents = responseDocuments(messageIdentifier, confirmationIdentifier),
            !documents.isAuthorized,
            let document = documents.documents.first(where: { $0.identifier == documentIdentifier })
        else { return }
        requestHostFlow(
            messageIdentifier, confirmationIdentifier,
            request: TanyaAIHostFlowRequest(
                identifier: UUID().uuidString, kind: .document, referenceIdentifier: document.identifier,
                title: document.title, destination: document.destination
            )
        )
    }

    func authorizeResponse(_ messageIdentifier: String, confirmationIdentifier: String, title: String) {
        guard isHostFlowEnabled, pendingHostFlow == nil,
            let documents = responseDocuments(messageIdentifier, confirmationIdentifier),
            documents.isReady, !documents.isAuthorized
        else { return }
        requestHostFlow(
            messageIdentifier, confirmationIdentifier,
            request: TanyaAIHostFlowRequest(
                identifier: UUID().uuidString, kind: .authorization,
                referenceIdentifier: confirmationIdentifier, title: title
            )
        )
    }

    func completeHostFlow(requestIdentifier: String, result: Result<TanyaAIHostFlowResult, Error>) {
        guard let pending = pendingHostFlow, pending.request.identifier == requestIdentifier else { return }
        pendingHostFlow = nil
        switch result {
        case .failure:
            errorMessage = copy.chat("chat.hostFlowFailed")
        case .success(let result):
            applyHostResult(result, pending: pending)
        }
    }
}

private extension TanyaAIChatViewModel {
    func requestHostFlow(
        _ messageIdentifier: String, _ confirmationIdentifier: String, request: TanyaAIHostFlowRequest
    ) {
        pendingHostFlow = PendingHostFlow(
            request: request, messageIdentifier: messageIdentifier, confirmationIdentifier: confirmationIdentifier
        )
        onOutput?(.requestHostFlow(request))
    }

    func responseDocuments(_ messageIdentifier: String, _ identifier: String) -> ResponseDocuments? {
        guard let message = message(identifier: messageIdentifier),
            case .response(let payload) = message.content
        else { return nil }
        for case .documents(let documents) in payload.blocks where documents.identifier == identifier {
            return documents
        }
        return nil
    }

    func applyHostResult(_ result: TanyaAIHostFlowResult, pending: PendingHostFlow) {
        guard let message = message(identifier: pending.messageIdentifier),
            case .response(var payload) = message.content
        else { return }
        payload.blocks = payload.blocks.map { block in
            guard case .documents(var documents) = block,
                documents.identifier == pending.confirmationIdentifier
            else { return block }
            if pending.request.kind == .document, result.status == .accepted {
                documents.acceptedIdentifiers.insert(pending.request.referenceIdentifier)
            } else if pending.request.kind == .authorization,
                result.status == .completed || result.status == .processing
            {
                documents.isAuthorized = true
            }
            return .documents(documents)
        }
        message.update(content: .response(payload))
        if pending.request.kind == .authorization, result.status == .completed || result.status == .processing,
            let text = result.message, !text.isEmpty
        {
            appendContent(identifier: "host-\(pending.request.identifier)", content: .text(text))
        }
    }
}
