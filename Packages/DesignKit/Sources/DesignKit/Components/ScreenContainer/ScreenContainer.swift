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
/// `background` (misalnya gambar latar) tampil di atas warna surface, di belakang header, konten dan footer.
@MainActor
public struct ScreenContainer<Content: View, Trailing: View, Footer: View, Background: View>: View {
    @Environment(\.designColors)
    private var colors
    // Keep the coordinate-space ID stable when the parent view updates.
    @State
    private var scrollSpaceID = UUID()
    @State
    private var isScrolled = false
    private let title: String
    private let backLabel: String
    private let onBack: () -> Void
    private let content: Content
    private let trailing: Trailing
    private let footer: Footer
    private let background: Background

    public init(
        title: String, backLabel: String, onBack: @escaping () -> Void,
        @ViewBuilder content: () -> Content, @ViewBuilder trailing: () -> Trailing,
        @ViewBuilder footer: () -> Footer, @ViewBuilder background: () -> Background
    ) {
        self.title = title
        self.backLabel = backLabel
        self.onBack = onBack
        self.content = content()
        self.trailing = trailing()
        self.footer = footer()
        self.background = background()
    }

    public var body: some View {
        VStack(spacing: .zero) {
            surface
            footer
        }
        .background(backdrop)
    }

    private var backdrop: some View {
        ZStack {
            colors.colorsSurfacePrimary
            background
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private var surface: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: .zero) { content }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
                    .padding(.top, CustomSizes.Header.height.scaledToArtwork + FigmaSize.spacingLarge.scaledToArtwork)
                    .padding(.bottom, FigmaSize.spacingLarge.scaledToArtwork)
                    .onScrollBoundaryChange(in: scrollSpaceID) { isScrolled = $0 }
            }
            .coordinateSpace(name: scrollSpaceID)
            ScreenHeader(
                title: title, backLabel: backLabel, isScrolled: isScrolled,
                onBack: onBack, trailing: { trailing }
            )
        }
    }
}

extension ScreenContainer where Background == EmptyView {
    public init(
        title: String, backLabel: String, onBack: @escaping () -> Void,
        @ViewBuilder content: () -> Content, @ViewBuilder trailing: () -> Trailing, @ViewBuilder footer: () -> Footer
    ) {
        self.init(
            title: title, backLabel: backLabel, onBack: onBack,
            content: content, trailing: trailing, footer: footer, background: { EmptyView() }
        )
    }
}

extension ScreenContainer where Trailing == EmptyView, Footer == EmptyView, Background == EmptyView {
    public init(
        title: String, backLabel: String, onBack: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: title, backLabel: backLabel, onBack: onBack,
            content: content, trailing: { EmptyView() }, footer: { EmptyView() }, background: { EmptyView() }
        )
    }
}
