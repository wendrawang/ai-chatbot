import TanyaAI
import TanyaAITestSupport

enum SandboxTanyaAIFactory {
    /// Builds the feature's dependencies with one of the two transports.
    ///
    /// - Parameters:
    ///   - showsShowcase: shortens the mock delay so a UI run does not wait on
    ///     simulated streaming.
    ///   - usesVendorSession: swaps the mock SSE transport for a mock vendor
    ///     chat session. Everything above the repository is identical, which
    ///     is what the mode demonstrates.
    static func makeDependencies(
        showsShowcase: Bool = false,
        usesVendorSession: Bool = false
    ) -> TanyaAIDependencies {
        guard usesVendorSession else {
            return TanyaAIDependencies(
                streamingTransport: MockTanyaAIStreamingTransport(
                    chunkDelay: showsShowcase ? 0.001 : 0.04
                ),
                authorizationService: MockTanyaAIAuthorizationService(),
                theme: .sandbox
            )
        }

        return TanyaAIDependencies(
            chatSession: MockTanyaAIChatSession.demo(
                deeplink: "tanyaaisandbox://mobile?type=transfer"
                    + "&accountNumber=0000111122",
                stepDelay: showsShowcase ? 0.01 : 0.05
            ),
            authorizationService: MockTanyaAIAuthorizationService(),
            theme: .sandbox
        )
    }
}
