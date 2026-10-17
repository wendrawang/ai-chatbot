//
//  View+ScrollBoundary.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI

public extension View {
    /// Apply to the scroll content, after its padding. Name the containing ScrollView with the same space.
    /// Reports the initial value, then only changes across the top boundary. Each observer is independent.
    @MainActor
    func onScrollBoundaryChange<Space: Hashable>(
        in coordinateSpace: Space, threshold: CGFloat = CustomSizes.Layout.measurementTolerance,
        perform: @escaping (Bool) -> Void
    ) -> some View {
        background {
            GeometryReader { geometry in
                let isScrolled =
                    geometry.frame(in: .named(coordinateSpace)).minY
                    < -max(.zero, threshold)
                Color.clear
                    .onAppear { perform(isScrolled) }
                    .onChange(of: isScrolled, perform: perform)
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
