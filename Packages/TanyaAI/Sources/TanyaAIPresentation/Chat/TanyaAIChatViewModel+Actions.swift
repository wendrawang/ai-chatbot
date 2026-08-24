import TanyaAIDomain

/// Approval and host-action intents.
///
/// The ViewModel decides nothing about navigation. It reports a typed output
/// and lets the router — and beyond it the host — decide what happens.
public extension TanyaAIChatViewModel {
    func approve(_ payload: TanyaAIApprovalPayload) {
        guard payload.state == .awaitingApproval else {
            return
        }
        if let handoff = payload.handoff {
            onOutput?(.performAction(handoff))
            return
        }
        onOutput?(.requestApproval(payload))
    }

    func perform(_ action: TanyaAIAction) {
        onOutput?(.performAction(action))
    }

    func editApproval(_ payload: TanyaAIApprovalPayload) {
        inputText = "Change \(payload.title.lowercased()): "
    }

    func cancelApproval(_ payload: TanyaAIApprovalPayload) {
        updateApproval(
            identifier: payload.approvalIdentifier,
            state: .cancelled
        )
    }

    func updateApproval(
        identifier: String,
        state: TanyaAIApprovalPayload.State
    ) {
        guard let message = approvalMessage(identifier: identifier),
              case .approval(var payload) = message.content else {
            return
        }
        payload.state = state
        message.update(content: .approval(payload))
    }
}
