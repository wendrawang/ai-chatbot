import TanyaAIContracts
import TanyaAIDesignSystem

public struct TanyaAIDependencies {
    public let streamingTransport: TanyaAIStreamingTransport
    public let authorizationService: TanyaAIAuthorizationService
    public let theme: TanyaAITheme

    public init(
        streamingTransport: TanyaAIStreamingTransport,
        authorizationService: TanyaAIAuthorizationService,
        theme: TanyaAITheme
    ) {
        self.streamingTransport = streamingTransport
        self.authorizationService = authorizationService
        self.theme = theme
    }
}
