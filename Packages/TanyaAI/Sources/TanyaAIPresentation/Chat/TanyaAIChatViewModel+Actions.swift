import TanyaAIDomain

/// Approval and hand-off intents.
///
/// The ViewModel decides nothing about navigation. It reports a typed output
/// and lets the coordinator - and beyond it the host - decide what happens.
public extension TanyaAIChatViewModel {
    /// Confirm on an approval bubble.
    ///
    /// With a `handoff` the deeplink goes to the host and the in-feature PIN
    /// sheet never opens. Without one the coordinator presents the PIN sheet
    /// and the injected authorization service runs.
    ///
    /// A host that authorizes nothing in chat injects no service. If a
    /// confirmation without a hand-off arrives anyway - a bot sending
    /// something this app cannot complete - it is refused in the open, not
    /// with a button that quietly does nothing.
    func approve(_ payload: TanyaAIApprovalPayload) {
        guard payload.state == .awaitingApproval else {
            return
        }
        if let handoff = payload.handoff {
            onOutput?(.performAction(handoff))
            return
        }
        guard authorizesInFeature else {
            reportUnauthorizableApproval()
            return
        }
        onOutput?(.requestApproval(payload))
    }

    /// A button on an action card. Reports the deeplink and nothing else.
    func perform(_ action: TanyaAIAction) {
        onOutput?(.performAction(action))
    }

    /// Edit on an approval bubble: seeds the input so the customer can restate
    /// the request in chat.
    func editApproval(_ payload: TanyaAIApprovalPayload) {
        inputText = "Change \(payload.title.lowercased()): "
    }

    /// Cancel on an approval bubble. Local state only: nothing is sent.
    func cancelApproval(_ payload: TanyaAIApprovalPayload) {
        updateApproval(
            identifier: payload.approvalIdentifier,
            state: .cancelled
        )
    }

    /// Moves one approval bubble to a new state, leaving the rest of the
    /// conversation untouched. Called by the coordinator as authorization
    /// progresses.
    func updateApproval(
        identifier: String,
        state: TanyaAIApprovalPayload.State
    ) {
        guard let message = approvalMessage(identifier: identifier),
              case .approval(var payload) = message.content,
              payload.state.isSettled == false else {
            // A late callback - a PIN sheet dismissed after the customer
            // already cancelled - must not revive a closed confirmation.
            return
        }
        payload.state = state
        message.update(content: .approval(payload))
    }
}
