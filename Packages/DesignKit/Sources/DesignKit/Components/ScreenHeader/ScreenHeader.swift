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
    private let title: String
    private let backLabel: String
    private let isScrolled: Bool
    private let fontFace: FontFace
    private let colors: any FigmaColorProtocol
    private let onBack: () -> Void
    private let trailing: Trailing

    public init(
        title: String, backLabel: String, isScrolled: Bool,
        fontFace: FontFace = .firaSansSemiBold, colors: any FigmaColorProtocol = DefaultColorConstants(),
        onBack: @escaping () -> Void, @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.backLabel = backLabel
        self.isScrolled = isScrolled
        self.fontFace = fontFace
        self.colors = colors
        self.onBack = onBack
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: FigmaSize.spacingMedium.scaledToArtwork) {
            backButton
            Text(title)
                .font(Font(fontFace.font(size: FigmaSize.typographySizeDisplayNormal16.scaledToArtwork)))
                .foregroundColor(colors.colorsTextPrimaryDark)
                .lineLimit(CustomSizes.Header.titleLines)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier(ComponentID.headerTitle)
            Color.clear.frame(width: tapSize, height: tapSize).overlay(trailing)
        }
        .padding(.horizontal, actionPadding)
        .frame(height: max(tapSize, CustomSizes.Header.height.scaledToArtwork))
        .background(surface.ignoresSafeArea(edges: .top))
        .overlay(alignment: .bottom) {
            if isScrolled {
                colors.colorsOutlineNetral.frame(height: FigmaSize.weightOutline.strokeInArtwork)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(isScrolled ? ComponentID.scrolledHeader : ComponentID.header)
    }

    private var backButton: some View {
        Button(action: onBack) {
            SystemSymbol.back.image.resizable().scaledToFit()
                .frame(
                    width: FigmaSize.weightIconSmall.scaledToArtwork,
                    height: FigmaSize.weightIconSmall.scaledToArtwork
                )
                .foregroundColor(colors.colorsIconColored)
                .frame(width: tapSize, height: tapSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(backLabel)
        .accessibilityIdentifier(ComponentID.back)
    }

    @ViewBuilder
    private var surface: some View {
        if isScrolled && !isTransparencyReduced {
            Rectangle().fill(.ultraThinMaterial)
        } else {
            colors.colorsSurfacePrimary
        }
    }

    private var tapSize: CGFloat { CustomSizes.ActionButton.minimumTapSize.tapTargetInArtwork }
    private var actionPadding: CGFloat {
        max(InitialValues.zeroCGFloat, FigmaSize.spacingLarge.scaledToArtwork - CustomSizes.Header.actionInset)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    public init(
        title: String, backLabel: String, isScrolled: Bool,
        fontFace: FontFace = .firaSansSemiBold, colors: any FigmaColorProtocol = DefaultColorConstants(),
        onBack: @escaping () -> Void
    ) {
        self.init(
            title: title, backLabel: backLabel, isScrolled: isScrolled,
            fontFace: fontFace, colors: colors, onBack: onBack, trailing: { EmptyView() }
        )
    }
}
