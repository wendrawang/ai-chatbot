//
//  ScreenHeader.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI

/// A centered title with equal action slots. The caller owns scroll state and navigation.
@MainActor
public struct ScreenHeader<Trailing: View>: View {
    @Environment(\.accessibilityReduceTransparency)
    private var isTransparencyReduced
    @Environment(\.designColors)
    private var colors
    private let title: String
    private let backLabel: String
    private let isScrolled: Bool
    private let titleStyle: DesignTextStyle
    private let onBack: () -> Void
    private let trailing: Trailing

    public init(
        title: String, backLabel: String, isScrolled: Bool,
        titleStyle: DesignTextStyle = .screenTitle, onBack: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.backLabel = backLabel
        self.isScrolled = isScrolled
        self.titleStyle = titleStyle
        self.onBack = onBack
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: FigmaSize.spacingMedium.scaledToArtwork) {
            backButton
            Text(title)
                .designFont(titleStyle)
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
        .overlay(alignment: .bottom) {
            if isScrolled {
                colors.colorsOutlineNetral.frame(height: FigmaSize.weightOutline.scaledToArtwork)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(isScrolled ? ComponentIdentifier.Header.scrolled : ComponentIdentifier.Header.root)
    }

    private var backButton: some View {
        Button(action: onBack) {
            Image(R.image.backArrow).resizable().scaledToFit()
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

    @ViewBuilder
    private var surface: some View {
        if isScrolled && !isTransparencyReduced {
            Rectangle().fill(.ultraThinMaterial)
        } else {
            colors.colorsSurfacePrimary
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
        titleStyle: DesignTextStyle = .screenTitle, onBack: @escaping () -> Void
    ) {
        self.init(
            title: title, backLabel: backLabel, isScrolled: isScrolled,
            titleStyle: titleStyle, onBack: onBack, trailing: { EmptyView() }
        )
    }
}
