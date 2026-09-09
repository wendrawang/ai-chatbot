import TanyaAI
import TanyaAITestSupport

enum SandboxTanyaAIFactory {
    /// The sandbox runs on a mock vendor session, the same seam a real SDK
    /// adapter plugs into.
    ///
    /// - Parameter showsShowcase: shortens the step delay so a UI run does not
    ///   wait on simulated streaming.
    static func makeDependencies(
        showsShowcase: Bool = false
    ) -> TanyaAIDependencies {
        TanyaAIDependencies(
            chatSession: MockTanyaAIChatSession.sandbox(
                stepDelay: showsShowcase ? 0.005 : 0.05
            ),
            authorizationService: MockTanyaAIAuthorizationService(),
            theme: .sandbox
        )
    }
}
