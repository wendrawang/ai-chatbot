import TanyaAI

enum SandboxTanyaAIFactory {
    static func makeDependencies() -> TanyaAIDependencies {
        TanyaAIDependencies(chatSession: figmaSession(), theme: figmaTheme)
    }
}
