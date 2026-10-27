//
//  ScreenContainerTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import Testing

extension HostWindowTests {
    @Test
    func multipleBuilderChildrenShareMarginsAndHeaderInset() throws {
        var firstFrame: CGRect?
        var secondFrame: CGRect?
        let content = ScreenContainer(
            title: "General screen", backLabel: "Back", onBack: {},
            content: {
                FrameSample { firstFrame = $0 }
                FrameSample { secondFrame = $0 }
            }
        )
        let fixture = try HostWindowFixture(content)
        defer { fixture.close() }
        let first = try #require(firstFrame)
        let second = try #require(secondFrame)
        #expect(abs(second.minY - first.maxY) <= 1)
        #expect(abs(first.minX - FigmaSize.spacingLarge.scaledToArtwork) <= 1)
        #expect(abs(second.minX - first.minX) <= 1)
        #expect(abs(second.width - first.width) <= 1)
        let expectedTop =
            fixture.controller.view.safeAreaInsets.top
            + CustomSizes.Header.height.scaledToArtwork + FigmaSize.spacingLarge.scaledToArtwork
        #expect(abs(first.minY - expectedTop) <= 1)
    }
}
