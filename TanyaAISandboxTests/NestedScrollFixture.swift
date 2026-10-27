//
//  NestedScrollFixture.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI

/// Scroll view di dalam scroll view; masing-masing melaporkan batas scroll-nya sendiri.
struct NestedScrollFixture: View {
    @State
    private var outerSpaceID = UUID()
    @State
    private var innerSpaceID = UUID()
    let onOuterChange: (Bool) -> Void
    let onInnerChange: (Bool) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ScrollView {
                    Color.clear.frame(height: 1_600)
                        .onScrollBoundaryChange(in: innerSpaceID, perform: onInnerChange)
                }
                .coordinateSpace(name: innerSpaceID)
                .frame(height: 200)
                Color.clear.frame(height: 1_600)
            }
            .onScrollBoundaryChange(in: outerSpaceID, perform: onOuterChange)
        }
        .coordinateSpace(name: outerSpaceID)
    }
}
