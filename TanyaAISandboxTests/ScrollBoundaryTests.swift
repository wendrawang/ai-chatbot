//
//  ScrollBoundaryTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import Testing

extension HostWindowTests {
    @MainActor
    struct ScrollBoundaryTests {
        @Test
        func nestedObserversOnlyReportTheirOwnBoundaryTransitions() throws {
            let outer = BoundaryProbe()
            let inner = BoundaryProbe()
            let fixture = try HostWindowFixture(NestedScrollFixture(outer: outer, inner: inner))
            defer { fixture.close() }
            let scrollViews = scrollViews(in: fixture.controller.view)
            #expect(scrollViews.count == 2)
            let outerScroll = try #require(scrollViews.max { $0.bounds.height < $1.bounds.height })
            let innerScroll = try #require(scrollViews.min { $0.bounds.height < $1.bounds.height })
            #expect(outer.values == [false])
            #expect(inner.values == [false])
            scroll(outerScroll, to: 0.2, fixture: fixture)
            #expect(outer.values == [false])
            for offset: CGFloat in [1, 40, 80, 120, 160, 200] {
                scroll(outerScroll, to: offset, fixture: fixture)
            }
            #expect(outer.values == [false, true])
            #expect(inner.values == [false])
            scroll(innerScroll, to: 80, fixture: fixture)
            #expect(inner.values == [false, true])
            #expect(outer.values == [false, true])
            scroll(innerScroll, to: 0, fixture: fixture)
            #expect(inner.values == [false, true, false])
            #expect(outer.values == [false, true])
            scroll(outerScroll, to: 0, fixture: fixture)
            #expect(outer.values == [false, true, false])
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
