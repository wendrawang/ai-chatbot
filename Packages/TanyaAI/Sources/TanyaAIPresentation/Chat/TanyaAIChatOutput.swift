import TanyaAIDomain

public enum TanyaAIChatOutput {
    case close
    case openHistory
    case requestApproval(TanyaAIApprovalPayload)
}
