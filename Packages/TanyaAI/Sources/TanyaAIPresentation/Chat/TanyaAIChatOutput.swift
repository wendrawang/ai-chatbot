import DesignKit
import TanyaAIDomain

public enum TanyaAIChatOutput {
    case close
    case openHistory
    case requestConfirmation(ConfirmationPayload)
    case requestApproval(ApprovalPayload)
    case performAction(Action)
}
