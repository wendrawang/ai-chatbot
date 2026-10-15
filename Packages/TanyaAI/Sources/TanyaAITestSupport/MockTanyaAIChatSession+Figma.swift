import Foundation

public extension MockTanyaAIChatSession {
    /// UI-only demo using the same session event seam as a real adapter.
    static func figma(stepDelay: TimeInterval = 0.3) -> MockTanyaAIChatSession {
        var productTitle = "Manulife Dana Kas II Kelas A"
        return MockTanyaAIChatSession(stepDelay: stepDelay) { prompt in
            if let selected = MockFigmaResponseFixture.selectedProduct(in: prompt) { productTitle = selected }
            return MockFigmaResponseFixture.events(for: prompt, productTitle: productTitle)
        }
    }
}
