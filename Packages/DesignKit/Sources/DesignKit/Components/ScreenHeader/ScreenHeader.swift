//
//  ScreenHeader.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI

/// A centered title with equal action slots. The caller owns scroll state and navigation.
/// Saat diam transparan, sehingga latar screen tembus sampai status bar. Saat konten digulir,
/// latar menjadi putih dan gradient tipis di bawahnya memudarkan konten yang lewat di belakangnya.
@MainActor
public struct ScreenHeader<Trailing: View>: View {
    @Environment(\.designColors)
    private var colors
    private let title: String
    private let backLabel: String
    private let isScrolled: Bool
    private let fontFace: FontFace
    private let onBack: () -> Void
    private let trailing: Trailing

    public init(
        title: String, backLabel: String, isScrolled: Bool,
        fontFace: FontFace = .firaSansSemiBold, onBack: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.backLabel = backLabel
        self.isScrolled = isScrolled
        self.fontFace = fontFace
        self.onBack = onBack
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: FigmaSize.spacingMedium.scaledToArtwork) {
            backButton
            Text(title)
                .font(fontFace.swiftUIFont(size: FigmaSize.typographySizeDisplayNormal16.scaledToArtwork))
                .foregroundColor(colors.colorsTextPrimaryDark)
                .lineLimit(CustomTextLines.headerTitle)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier(ComponentIdentifier.Header.title)
            Color.clear.frame(width: actionSize, height: actionSize).overlay(trailing)
        }
        .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
        .frame(height: CustomSizes.Header.height.scaledToArtwork)
        .background(surface.ignoresSafeArea(edges: .top))
        .overlay(alignment: .bottom) { fade }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(isScrolled ? ComponentIdentifier.Header.scrolled : ComponentIdentifier.Header.root)
    }

    private var backButton: some View {
        Button(action: onBack) {
            Image(DesignIcon.backArrow).resizable().scaledToFit()
                .frame(
                    width: actionSize,
                    height: actionSize
                )
                .foregroundColor(colors.colorsIconColored)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(backLabel)
        .accessibilityIdentifier(ComponentIdentifier.Header.back)
    }

    private var surface: some View {
        isScrolled ? colors.colorsSurfacePrimary : Color.clear
    }

    /// Di luar frame header: tidak mengubah tinggi header dan tidak menangkap sentuhan.
    @ViewBuilder
    private var fade: some View {
        if isScrolled {
            LinearGradient(
                colors: [colors.colorsSurfacePrimary, colors.colorsSurfacePrimary.opacity(.zero)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: FigmaSize.spacingLarge.scaledToArtwork)
            .offset(y: FigmaSize.spacingLarge.scaledToArtwork)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

// MARK: - Helpers

private extension ScreenHeader {
    var actionSize: CGFloat { FigmaSize.weightIconSmall.scaledToArtwork }
}

extension ScreenHeader where Trailing == EmptyView {
    public init(
        title: String, backLabel: String, isScrolled: Bool,
        fontFace: FontFace = .firaSansSemiBold, onBack: @escaping () -> Void
    ) {
        self.init(
            title: title, backLabel: backLabel, isScrolled: isScrolled,
            fontFace: fontFace, onBack: onBack, trailing: { EmptyView() }
        )
    }
}
