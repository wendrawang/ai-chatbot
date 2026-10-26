//
//  SurfaceStyleTests.swift
//  DesignKit
//
//  Created by Wendra on 22/10/26.
//

import SwiftUI
import XCTest

@testable import DesignKit

@MainActor
final class SurfaceStyleTests: XCTestCase {
    func testSurfaceStylesOnlyDrawBehindContentWithoutChangingLayout() {
        let plain = size(of: Text("Kartu").padding())
        XCTAssertEqual(size(of: Text("Kartu").padding().cardStyle()), plain)
        XCTAssertEqual(size(of: Text("Kartu").padding().designShadow()), plain)
    }
}

// MARK: - Helpers

private extension SurfaceStyleTests {
    func size(of content: some View) -> CGSize {
        UIHostingController(rootView: content).sizeThatFits(in: CGSize(width: 375, height: 800))
    }
}
