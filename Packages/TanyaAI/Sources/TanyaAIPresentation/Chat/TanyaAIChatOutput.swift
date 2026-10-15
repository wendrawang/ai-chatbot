import TanyaAIContracts
import TanyaAIDomain

public enum TanyaAIChatOutput {
    case close
    case startNewSession
    case requestHostFlow(TanyaAIHostFlowRequest)
    case performAction(Action)
}
