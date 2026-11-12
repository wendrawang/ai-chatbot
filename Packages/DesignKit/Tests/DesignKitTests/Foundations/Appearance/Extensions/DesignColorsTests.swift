//
//  DesignColorsTests.swift
//  DesignKit
//
//  Created by Wendra on 17/10/26.
//

import SwiftUI
import Testing

@testable import DesignKit

@MainActor
struct DesignColorsTests {
    @Test
    func defaultPaletteWithoutHostTheme() {
        var palette: (any FigmaColorProtocol)?
        render(PaletteReader { palette = $0 })
        #expect(palette is DefaultColorConstants)
    }

    @Test
    func themeReachesNestedComponents() {
        var palette: (any FigmaColorProtocol)?
        render(VStack { PaletteReader { palette = $0 } }.designColors(PremierColorConstants()))
        #expect(palette is PremierColorConstants)
    }

    @Test
    func defaultAreaIgnoresParentTheme() {
        var themed: (any FigmaColorProtocol)?
        var untouched: (any FigmaColorProtocol)?
        render(
            VStack {
                PaletteReader { themed = $0 }
                VStack { PaletteReader { untouched = $0 } }.defaultDesignColors()
            }
            .designColors(PrivateColorConstants())
        )
        #expect(themed is PrivateColorConstants)
        #expect(untouched is DefaultColorConstants)
    }

    private func render(_ content: some View) {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 200))
        window.rootViewController = UIHostingController(rootView: content)
        window.makeKeyAndVisible()
        window.rootViewController?.view.layoutIfNeeded()
        window.isHidden = true
    }
}
