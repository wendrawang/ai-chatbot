import SwiftUI
import XCTest
@testable import DesignKit

@MainActor
final class ThemeManagerTests: XCTestCase {
    func testSelectionAndPageOverrideStayIndependent() {
        let fonts = Theme.sandbox.fonts
        let manager = ThemeManager(fonts: fonts)
        let defaultTheme = manager.theme

        manager.selected = .premier
        XCTAssertEqual(manager.theme.colors.accent, UIColor(PremierColorConstants().colorsButtonActive))
        XCTAssertNotEqual(manager.theme, defaultTheme)
        XCTAssertEqual(manager.resolve(isDefaultForced: true), defaultTheme)
        XCTAssertEqual(manager.selected, .premier)

        manager.selected = .private
        XCTAssertEqual(manager.theme.colors.accent, UIColor(PrivateColorConstants().colorsButtonActive))
        XCTAssertEqual(manager.resolve(isDefaultForced: true), defaultTheme)
    }

    func testGlobalOverridePreservesSelectedTheme() {
        let manager = ThemeManager(fonts: Theme.sandbox.fonts, selected: .premier)
        let premierTheme = manager.theme

        manager.isDefaultForced = true
        manager.selected = .private
        XCTAssertEqual(manager.theme.colors.accent, UIColor(DefaultColorConstants().colorsButtonActive))

        manager.isDefaultForced = false
        XCTAssertEqual(manager.selected, .private)
        XCTAssertNotEqual(manager.theme, premierTheme)
        XCTAssertEqual(manager.theme.colors.accent, UIColor(PrivateColorConstants().colorsButtonActive))
    }

    func testGeneratedAdapterPreservesTextAndSurfaceTokens() {
        let tokens = DefaultColorConstants()
        let theme = Theme(tokens: tokens, fonts: Theme.sandbox.fonts)
        XCTAssertEqual(theme.colors.background, UIColor(tokens.colorsSurfacePrimary))
        XCTAssertEqual(theme.colors.primaryText, UIColor(tokens.colorsTextPrimaryDark))
        XCTAssertEqual(theme.colors.divider, UIColor(tokens.colorsOutlineNetral))
    }
}
