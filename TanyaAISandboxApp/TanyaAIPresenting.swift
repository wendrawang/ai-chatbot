import TanyaAI

/// What existing screens depend on. They stay unaware of Tanya AI itself.
protocol TanyaAIPresenting: AnyObject {
    func presentTanyaAI()

    /// Opens the feature carrying what this screen already knows, so the
    /// customer does not have to repeat it.
    func presentTanyaAI(context: TanyaAIContext?)

    func dismissTanyaAI()
}

extension TanyaAIPresenting {
    func presentTanyaAI(context: TanyaAIContext?) {
        presentTanyaAI()
    }
}
