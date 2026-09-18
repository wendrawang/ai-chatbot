import TanyaAI
import TanyaAITestSupport

enum SandboxTanyaAIFactory {
    /// What a host would fetch from its own backend before opening the chat.
    ///
    /// Hardcoded here because the sandbox has no backend; in an application
    /// these arrive from an inquiry and are passed straight in.
    static var shortcuts: [TanyaAISuggestion] {
        [
            TanyaAISuggestion(
                identifier: "shortcut-transfer",
                title: "Transfer",
                prompt: "Saya mau transfer"
            ),
            TanyaAISuggestion(
                identifier: "shortcut-spending",
                title: "Pengeluaran",
                prompt: "Tampilkan spending saya"
            ),
            TanyaAISuggestion(
                identifier: "shortcut-limit",
                title: "Limit transfer",
                prompt: "Berapa limit transfer saya"
            )
        ]
    }

    /// The sandbox runs on a mock vendor session, the same seam a real SDK
    /// adapter plugs into.
    ///
    /// - Parameter isShowcaseVisible: shortens the step delay so a UI run does not
    ///   wait on simulated streaming.
    static func makeDependencies(
        isShowcaseVisible: Bool = false
    ) -> TanyaAIDependencies {
        TanyaAIDependencies(
            chatSession: MockTanyaAIChatSession.sandbox(
                stepDelay: isShowcaseVisible ? 0.005 : 0.05
            ),
            authorizationService: MockTanyaAIAuthorizationService(),
            theme: .sandbox
        )
    }
}
