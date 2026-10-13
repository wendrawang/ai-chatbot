import DesignKit
import TanyaAIContracts
import TanyaAIDomain

public enum TanyaAIChatOutput {
    case close
    case openHistory
    case startNewSession
    case requestHostFlow(TanyaAIHostFlowRequest)
    case requestConfirmation(ConfirmationPayload)
    case requestApproval(ApprovalPayload)
    case performAction(Action)
}
