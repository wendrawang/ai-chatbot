extension TanyaAIChatViewModel {
    func message(identifier: String) -> TanyaAIMessageItemViewModel? {
        messages.first { $0.identifier == identifier }
    }
}
