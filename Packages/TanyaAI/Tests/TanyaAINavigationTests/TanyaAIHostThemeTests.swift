import DesignKit
import TanyaAITestSupport
import XCTest

@testable import TanyaAI

@MainActor
final class TanyaAIHostThemeTests: XCTestCase {
    func testProviderIsReadAgainForEachPresentationSnapshot() {
        var selected = Theme.sandbox
        let original = selected
        let host = TanyaAIHost(
            theme: .sandbox, themeProvider: { selected }, deeplinkScheme: "sample",
            makeSession: { MockTanyaAIChatSession.figma() }, onDeeplink: { _ in }
        )
        XCTAssertEqual(host.presentationTheme, original)
        selected = Theme(tokens: PremierColorConstants(), fonts: original.fonts)
        XCTAssertEqual(host.presentationTheme, selected)
        XCTAssertNotEqual(host.presentationTheme, original)
    }
}
