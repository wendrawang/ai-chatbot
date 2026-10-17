//
//  ScrollBoundaryTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import XCTest

@MainActor
final class ScrollBoundaryTests: XCTestCase {
    func testNestedObserversOnlyReportTheirOwnBoundaryTransitions() throws {
        let outer = BoundaryProbe()
        let inner = BoundaryProbe()
        let fixture = try HostWindowFixture(NestedScrollFixture(outer: outer, inner: inner))
        defer { fixture.close() }
        let scrollViews = scrollViews(in: fixture.controller.view)
        XCTAssertEqual(scrollViews.count, 2)
        let outerScroll = try XCTUnwrap(scrollViews.max { $0.bounds.height < $1.bounds.height })
        let innerScroll = try XCTUnwrap(scrollViews.min { $0.bounds.height < $1.bounds.height })
        XCTAssertEqual(outer.values, [false])
        XCTAssertEqual(inner.values, [false])
        scroll(outerScroll, to: 0.2, fixture: fixture)
        XCTAssertEqual(outer.values, [false])
        for offset: CGFloat in [1, 40, 80, 120, 160, 200] {
            scroll(outerScroll, to: offset, fixture: fixture)
        }
        XCTAssertEqual(outer.values, [false, true])
        XCTAssertEqual(inner.values, [false])
        scroll(innerScroll, to: 80, fixture: fixture)
        XCTAssertEqual(inner.values, [false, true])
        XCTAssertEqual(outer.values, [false, true])
        scroll(innerScroll, to: 0, fixture: fixture)
        XCTAssertEqual(inner.values, [false, true, false])
        XCTAssertEqual(outer.values, [false, true])
        scroll(outerScroll, to: 0, fixture: fixture)
        XCTAssertEqual(outer.values, [false, true, false])
    }

    private func scroll(_ view: UIScrollView, to offset: CGFloat, fixture: HostWindowFixture) {
        view.setContentOffset(CGPoint(x: 0, y: offset - view.adjustedContentInset.top), animated: false)
        fixture.settle()
    }

    private func scrollViews(in view: UIView) -> [UIScrollView] {
        let current = (view as? UIScrollView).map { [$0] } ?? []
        return current + view.subviews.flatMap { scrollViews(in: $0) }
    }
}

private final class BoundaryProbe {
    var values: [Bool] = []
    func record(_ isScrolled: Bool) { values.append(isScrolled) }
}

private struct NestedScrollFixture: View {
    @State
    private var outerSpaceID = UUID()
    @State
    private var innerSpaceID = UUID()
    let outer: BoundaryProbe
    let inner: BoundaryProbe

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ScrollView {
                    Color.clear.frame(height: 1_600)
                        .onScrollBoundaryChange(in: innerSpaceID, perform: inner.record)
                }
                .coordinateSpace(name: innerSpaceID)
                .frame(height: 200)
                Color.clear.frame(height: 1_600)
            }
            .onScrollBoundaryChange(in: outerSpaceID, perform: outer.record)
        }
        .coordinateSpace(name: outerSpaceID)
    }
}
