public enum TanyaAIConnectionState: Equatable {
    case connecting
    case ready
    case failed
    case closed
}

public enum TanyaAIMessageDelivery: Equatable {
    case pending
    case sent
    case failed
}
