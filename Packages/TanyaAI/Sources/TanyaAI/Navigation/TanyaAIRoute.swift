import TanyaAIDomain

enum TanyaAIRoute {
    case chat
    case history
    case approval(TanyaAIApprovalPayload)
}
