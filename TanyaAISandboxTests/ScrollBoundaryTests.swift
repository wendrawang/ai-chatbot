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
    @Test
    func nestedObserversOnlyReportTheirOwnBoundaryTransitions() throws {
        var outer: [Bool] = []
        var inner: [Bool] = []
        let fixture = try HostWindowFixture(
            NestedScrollFixture(onOuterChange: { outer.append($0) }, onInnerChange: { inner.append($0) }))
        defer { fixture.close() }
        let scrollViews = scrollViews(in: fixture.controller.view)
        #expect(scrollViews.count == 2)
        let outerScroll = try #require(scrollViews.max { $0.bounds.height < $1.bounds.height })
        let innerScroll = try #require(scrollViews.min { $0.bounds.height < $1.bounds.height })
        #expect(outer == [false])
        #expect(inner == [false])
        scroll(outerScroll, to: 0.2, fixture: fixture)
        #expect(outer == [false])
        for offset: CGFloat in [1, 40, 80, 120, 160, 200] {
            scroll(outerScroll, to: offset, fixture: fixture)
        }
        #expect(outer == [false, true])
        #expect(inner == [false])
        scroll(innerScroll, to: 80, fixture: fixture)
        #expect(inner == [false, true])
        #expect(outer == [false, true])
        scroll(innerScroll, to: 0, fixture: fixture)
        #expect(inner == [false, true, false])
        #expect(outer == [false, true])
        scroll(outerScroll, to: 0, fixture: fixture)
        #expect(outer == [false, true, false])
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
