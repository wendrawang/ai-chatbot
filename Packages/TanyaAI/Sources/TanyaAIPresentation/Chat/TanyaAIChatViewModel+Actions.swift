import TanyaAIContracts
import TanyaAIDomain

/// Approval and hand-off intents.
///
/// The ViewModel decides nothing about navigation. It reports a typed output
/// and lets the router — and beyond it the host — decide what happens.
public extension TanyaAIChatViewModel {
    /// Confirm on an approval bubble.
    ///
    /// With a `handoff` the deeplink goes to the host and the in-feature PIN
    /// sheet never opens. Without one the flow is unchanged: the router
    /// presents the PIN sheet and the injected authorization service runs.
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

    /// The customer dismissed the context chip: stop sending the context from
    /// the next message on. Messages already sent kept it, which is exactly
    /// why the chip is visible in the first place.
    func clearContext() {
        setContextSummary(nil)
        useCase.updateContext(nil)
    }

    /// A button on an action card. Reports the deeplink and nothing else.
    func perform(_ action: TanyaAIAction) {
        onOutput?(.performAction(action))
    }

    /// Edit on an approval bubble: seeds the input so the user can restate the
    /// request in chat.
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
    /// conversation untouched. Called by the router as authorization
    /// progresses.
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
