import DesignKit
import TanyaAIDomain

public enum TanyaAIChatOutput {
    case close
    case openHistory
    case requestApproval(ApprovalPayload)
    case performAction(Action)
}
