import TanyaAI
import TanyaAITestSupport

enum SandboxTanyaAIFactory {
    static func makeDependencies(
        showsShowcase: Bool = false
    ) -> TanyaAIDependencies {
        let transport = MockTanyaAIStreamingTransport(
            chunkDelay: showsShowcase ? 0.001 : 0.04
        )
        return TanyaAIDependencies(
            streamingTransport: transport,
            authorizationService: MockTanyaAIAuthorizationService(),
            theme: .sandbox
        )
    }
}
