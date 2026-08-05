import TanyaAIContracts

public enum TanyaAIPINOutput {
    case started
    case cancel
    case completed(TanyaAIAuthorizationResult)
}
