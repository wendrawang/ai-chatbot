//
//  ScreenContainer.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import SwiftUI

/// Shared scrolling screen layout. Supply content, not another vertical ScrollView.
/// Navigation callbacks and the footer's padding belong to the caller.
@MainActor
public struct ScreenContainer<Content: View, Trailing: View, Footer: View>: View {
    // Keep the coordinate-space ID stable when the parent view updates.
    @State
    private var scrollSpaceID = UUID()
    @State
    private var isScrolled = false
    private let title: String
    private let backLabel: String
    private let colors: any FigmaColorProtocol
    private let onBack: () -> Void
    private let content: Content
    private let trailing: Trailing
    private let footer: Footer

    public init(
        title: String, backLabel: String, colors: any FigmaColorProtocol = DefaultColorConstants(),
        onBack: @escaping () -> Void, @ViewBuilder content: () -> Content,
        @ViewBuilder trailing: () -> Trailing, @ViewBuilder footer: () -> Footer
    ) {
        self.title = title
        self.backLabel = backLabel
        self.colors = colors
        self.onBack = onBack
        self.content = content()
        self.trailing = trailing()
        self.footer = footer()
    }

    public var body: some View {
        VStack(spacing: InitialValues.zeroCGFloat) {
            surface
            footer
        }
        .background(colors.colorsSurfacePrimary.ignoresSafeArea())
    }

    private var surface: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: InitialValues.zeroCGFloat) { content }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
                    .padding(.top, CustomSizes.Header.scaledHeight + FigmaSize.spacingLarge.scaledToArtwork)
                    .padding(.bottom, FigmaSize.spacingLarge.scaledToArtwork)
                    .onScrollBoundaryChange(in: scrollSpaceID) { isScrolled = $0 }
            }
            .coordinateSpace(name: scrollSpaceID)
            ScreenHeader(
                title: title, backLabel: backLabel, isScrolled: isScrolled,
                colors: colors, onBack: onBack, trailing: { trailing }
            )
        }
    }
}

extension ScreenContainer where Trailing == EmptyView, Footer == EmptyView {
    public init(
        title: String, backLabel: String, colors: any FigmaColorProtocol = DefaultColorConstants(),
        onBack: @escaping () -> Void, @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: title, backLabel: backLabel, colors: colors, onBack: onBack,
            content: content, trailing: { EmptyView() }, footer: { EmptyView() }
        )
    }
}
