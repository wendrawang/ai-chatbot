//
//  DesignColorsTests.swift
//  DesignKit
//
//  Created by Wendra on 17/10/26.
//

import SwiftUI
import XCTest

@testable import DesignKit

@MainActor
final class DesignColorsTests: XCTestCase {
    func testDefaultPaletteWithoutHostTheme() {
        let probe = PaletteProbe()
        render(PaletteReader(probe: probe))
        XCTAssertTrue(probe.palette is DefaultColorConstants)
    }

    func testThemeReachesNestedComponents() {
        let probe = PaletteProbe()
        render(VStack { PaletteReader(probe: probe) }.designColors(PremierColorConstants()))
        XCTAssertTrue(probe.palette is PremierColorConstants)
    }

    func testDefaultAreaIgnoresParentTheme() {
        let themed = PaletteProbe()
        let untouched = PaletteProbe()
        render(
            VStack {
                PaletteReader(probe: themed)
                VStack { PaletteReader(probe: untouched) }.defaultDesignColors()
            }
            .designColors(PrivateColorConstants())
        )
        XCTAssertTrue(themed.palette is PrivateColorConstants)
        XCTAssertTrue(untouched.palette is DefaultColorConstants)
    }

    private func render(_ content: some View) {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 200))
        window.rootViewController = UIHostingController(rootView: content)
        window.makeKeyAndVisible()
        window.rootViewController?.view.layoutIfNeeded()
        window.isHidden = true
    }
}

private final class PaletteProbe {
    var palette: (any FigmaColorProtocol)?
}

private struct PaletteReader: View {
    @Environment(\.designColors)
    private var colors
    let probe: PaletteProbe

    var body: some View {
        probe.palette = colors
        return Color.clear.frame(width: 1, height: 1)
    }
}
