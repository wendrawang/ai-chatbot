//
//  ScreenContainerTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import XCTest

@MainActor
final class ScreenContainerTests: XCTestCase {
    func testMultipleBuilderChildrenShareMarginsAndHeaderInset() throws {
        let first = FrameProbe()
        let second = FrameProbe()
        let content = ScreenContainer(
            title: "General screen", backLabel: "Back", onBack: {},
            content: {
                FrameSample(probe: first)
                FrameSample(probe: second)
            }
        )
        let fixture = try HostWindowFixture(content)
        defer { fixture.close() }
        let firstFrame = try XCTUnwrap(first.frame)
        let secondFrame = try XCTUnwrap(second.frame)
        XCTAssertEqual(secondFrame.minY, firstFrame.maxY, accuracy: 1)
        XCTAssertEqual(firstFrame.minX, FigmaSize.spacingLarge.scaledToArtwork, accuracy: 1)
        XCTAssertEqual(secondFrame.minX, firstFrame.minX, accuracy: 1)
        XCTAssertEqual(secondFrame.width, firstFrame.width, accuracy: 1)
        let expectedTop =
            fixture.controller.view.safeAreaInsets.top
            + CustomSizes.Header.scaledHeight + FigmaSize.spacingLarge.scaledToArtwork
        XCTAssertEqual(firstFrame.minY, expectedTop, accuracy: 1)
    }
}

private final class FrameProbe {
    var frame: CGRect?
}

private struct FrameSample: View {
    let probe: FrameProbe
    var body: some View {
        Color.clear.frame(height: 50)
            .background {
                GeometryReader { geometry in
                    Color.clear.onAppear { probe.frame = geometry.frame(in: .global) }
                }
            }
    }
}
