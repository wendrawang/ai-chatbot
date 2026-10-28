//
//  ScreenHeader.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI

/// A centered title with equal action slots. The caller owns scroll state and navigation.
/// Ukuran mengikuti navigation bar host: header mulai dari tepi atas layar (caller menaruhnya tanpa
/// safe area atas), padding atas `CustomScreenInsets` tanpa scale, ikon 24, judul Fira Sans Bold 16.
/// Saat diam transparan, sehingga latar screen tembus sampai status bar. Saat konten digulir,
/// latar menjadi putih dengan bayangan Figma `Shadow/Default` sehingga header terangkat seperti kartu.
@MainActor
public struct ScreenHeader<Trailing: View>: View {
    @Environment(\.designColors)
    private var colors
    private let title: String
    private let backLabel: String
    private let isScrolled: Bool
    private let isNotched: Bool
    private let fontFace: FontFace
    private let onBack: () -> Void
    private let trailing: Trailing

    /// `isNotched` dari `ScreenHeader.isNotched(safeAreaTop:)`; menentukan padding atas dari tepi layar.
    public init(
        title: String, backLabel: String, isScrolled: Bool, isNotched: Bool,
        fontFace: FontFace = .firaSansBold, onBack: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.backLabel = backLabel
        self.isScrolled = isScrolled
        self.isNotched = isNotched
        self.fontFace = fontFace
        self.onBack = onBack
        self.trailing = trailing()
    }

    public var body: some View {
        // Seperti host: judul selebar bar dengan padding sendiri, tombol di lapisan atasnya.
        ZStack {
            titleText
            HStack(spacing: .zero) {
                backButton
                Spacer(minLength: .zero)
                Color.clear.frame(width: actionSize, height: actionSize).overlay(trailing)
            }
        }
        .padding(.horizontal, CustomSizes.Header.horizontalPadding.scaledToArtwork)
        .padding(.top, isNotched ? CustomScreenInsets.headerTopWithNotch : CustomScreenInsets.headerTop)
        .padding(.bottom, CustomSizes.Header.bottomPadding.scaledToArtwork)
        .background(surface)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(isScrolled ? ComponentIdentifier.Header.scrolled : ComponentIdentifier.Header.root)
    }

    private var titleText: some View {
        Text(title)
            .font(fontFace.swiftUIFont(size: FigmaSize.typographySizeDisplayNormal16.scaledToArtwork))
            .foregroundColor(colors.colorsTextPrimaryDark)
            .multilineTextAlignment(.center)
            .lineLimit(CustomTextLines.headerTitle)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, FigmaSize.spacingExtraLarge.scaledToArtwork)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(ComponentIdentifier.Header.title)
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

    /// Bayangan digambar di luar frame: tinggi header tetap dan sentuhan tidak tertangkap.
    /// Bayangan dari `Color.clear` tidak terlihat, jadi saat diam header tetap transparan penuh.
    private var surface: some View {
        (isScrolled ? colors.colorsSurfacePrimary : Color.clear).designShadow()
    }
}

// MARK: - Helpers

private extension ScreenHeader {
    var actionSize: CGFloat { FigmaSize.weightIconSmall.scaledToArtwork }
}

extension ScreenHeader where Trailing == EmptyView {
    public init(
        title: String, backLabel: String, isScrolled: Bool, isNotched: Bool,
        fontFace: FontFace = .firaSansBold, onBack: @escaping () -> Void
    ) {
        self.init(
            title: title, backLabel: backLabel, isScrolled: isScrolled, isNotched: isNotched,
            fontFace: fontFace, onBack: onBack, trailing: { EmptyView() }
        )
    }

    /// Notch / Dynamic Island bila safe area atas melebihi status bar klasik. Memakai safe area atas,
    /// bukan bawah seperti host, supaya keyboard (yang menambah inset bawah) tidak menggeser header.
    public static func isNotched(safeAreaTop: CGFloat) -> Bool {
        safeAreaTop > CustomScreenInsets.classicStatusBar
    }

    /// Tinggi header dari tepi atas layar; konten di bawah header mulai setelah nilai ini.
    public static func height(isNotched: Bool) -> CGFloat {
        (isNotched ? CustomScreenInsets.headerTopWithNotch : CustomScreenInsets.headerTop)
            + FigmaSize.weightIconSmall.scaledToArtwork
            + CustomSizes.Header.bottomPadding.scaledToArtwork
    }
}
