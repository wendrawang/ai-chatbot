import DesignKit
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
    func approve(_ payload: ApprovalPayload) {
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

    /// A chip on a choices bubble.
    ///
    /// Local state only: nothing reaches the bot until submit. That is the
    /// entire point of the bubble - a customer may change their mind, and a
    /// half-formed answer should never become a turn.
    func toggleChoice(_ payload: ChoicesPayload, _ identifier: String) {
        guard payload.isSubmitted == false,
              let message = choicesMessage(identifier: payload.identifier),
              case .choices(let current) = message.content,
              current.isSubmitted == false else {
            return
        }
        message.update(content: .choices(current.toggling(identifier)))
    }

    /// Submit on a choices bubble. Sends the answer and settles the card.
    ///
    /// The card stays on screen, disabled. The conversation is the record of
    /// what was asked and what was answered, so removing the question once it
    /// has been answered would erase half of that.
    func submitChoices(_ payload: ChoicesPayload) {
        guard let message = choicesMessage(identifier: payload.identifier),
              case .choices(var current) = message.content,
              current.canSubmit else {
            return
        }
        current.isSubmitted = true
        message.update(content: .choices(current))
        sendMessage(current.answerPrompt)
    }

    /// Declining a live-agent offer. Local state only: nothing is sent, and
    /// the card stays on screen showing that it was declined.
    ///
    /// Accepting is not here. It goes through `perform` like any other
    /// hand-off, and deliberately does not settle the card: a customer who
    /// comes back may want to connect again.
    func declineLiveAgent(_ payload: LiveAgentPayload) {
        guard let message = liveAgentMessage(identifier: payload.identifier),
              case .liveAgent(var current) = message.content,
              current.isDeclined == false else {
            return
        }
        current.isDeclined = true
        message.update(content: .liveAgent(current))
    }

    /// A button on an action card. Reports the deeplink and nothing else.
    func perform(_ action: Action) {
        onOutput?(.performAction(action))
    }

    /// Edit on an approval bubble: seeds the input so the customer can restate
    /// the request in chat.
    func editApproval(_ payload: ApprovalPayload) {
        inputText = "Change \(payload.title.lowercased()): "
    }

    /// Cancel on an approval bubble. Local state only: nothing is sent.
    func cancelApproval(_ payload: ApprovalPayload) {
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
        state: ApprovalPayload.State
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
