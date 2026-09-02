import TanyaAIDomain

enum TanyaAIWelcomeMessageFactory {
    static func makeMessage() -> TanyaAIMessageItemViewModel {
        let message = TanyaAIMessage(
            identifier: "sandbox-welcome",
            role: .assistant,
            content: .text(
                "[bold]Welcome to the sanitized Tanya AI "
                    + "sandbox.[/bold] "
                    + "Ask for a sample portfolio to start the demo."
            )
        )
        return TanyaAIMessageItemViewModel(message: message)
    }
}
