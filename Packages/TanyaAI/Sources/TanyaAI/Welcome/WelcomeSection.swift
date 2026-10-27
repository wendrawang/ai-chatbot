//
//  WelcomeSection.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

import DesignKit
import SwiftUI

/// Halaman sambutan: emblem, sapaan dari BE, lalu kartu shortcut. Ikon kartu dari `iconURL` BE,
/// chevron dan judul daftar milik FE. Kartu nonaktif selama menunggu jawaban.
/// TODO: Cocokkan jarak dan role tipografi dengan Figma; sementara estimasi dari screenshot.
@MainActor
struct WelcomeSection: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.designColors)
    private var colors
    private let content: WelcomeContent
    private let isEnabled: Bool
    private let onSelect: (WelcomeShortcut) -> Void

    init(content: WelcomeContent, isEnabled: Bool, onSelect: @escaping (WelcomeShortcut) -> Void) {
        self.content = content
        self.isEnabled = isEnabled
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: FigmaSize.spacingExtraLarge.scaledToArtwork) {
            greeting
            shortcuts
        }
        .padding(.top, FigmaSize.spacingDoubleExtraLarge.scaledToArtwork)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ChatElementIdentifier.welcome)
    }

    private var greeting: some View {
        VStack(spacing: FigmaSize.spacingLarge.scaledToArtwork) {
            Image(ChatImage.welcomeOrb).resizable().scaledToFit()
                .frame(width: CustomSizes.Emblem.size.scaledToArtwork, height: CustomSizes.Emblem.size.scaledToArtwork)
                .accessibilityHidden(true)
            VStack(spacing: FigmaSize.spacingSmall.scaledToArtwork) {
                Text(content.greetings.title)
                    .font(Font(titleFont))
                    .lineSpacing(titleFont.lineSpacing(forLineHeight: titleLineHeight))
                    .foregroundColor(colors.colorsTextPrimaryDark)
                    .accessibilityAddTraits(.isHeader)
                Text(content.greetings.description)
                    .font(Font(bodyFont))
                    .lineSpacing(bodyFont.lineSpacing(forLineHeight: bodyLineHeight))
                    .foregroundColor(colors.colorsTextSecondary)
            }
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
    }

    private var shortcuts: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacingMedium.scaledToArtwork) {
            shortcutsTitle
            ForEach(Array(content.shortcuts.enumerated()), id: \.offset) { index, shortcut in
                ActionCard(
                    title: shortcut.title, description: shortcut.description, isEnabled: isEnabled,
                    onTap: { onSelect(shortcut) },
                    icon: {
                        RemoteImage(
                            url: shortcut.iconURL, pointSize: iconSize, placeholder: { Color.clear },
                            fallback: { fallbackIcon }
                        )
                    }
                )
                .accessibilityIdentifier(ChatElementIdentifier.shortcut(index))
            }
        }
    }

    /// Ikon FE saat `iconUrl` kosong/tidak valid atau gagal diunduh; kartu tetap bisa diketuk.
    /// TODO: Ganti dengan ikon default dari desain bila tersedia.
    private var fallbackIcon: some View {
        Image(DesignIcon.lightbulb).resizable().scaledToFit()
            .foregroundColor(colors.colorsIconColored)
    }

    private var shortcutsTitle: some View {
        HStack(spacing: FigmaSize.spacingSmall.scaledToArtwork) {
            Image(DesignIcon.lightbulb).resizable().scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundColor(colors.colorsIconColored)
                .accessibilityHidden(true)
            Text(String(ChatCopy.shortcutsTitle, locale: locale))
                .font(Font(sectionFont))
                .lineSpacing(sectionFont.lineSpacing(forLineHeight: bodyLineHeight))
                .foregroundColor(colors.colorsTextPrimaryDark)
                .accessibilityAddTraits(.isHeader)
        }
    }
}

// MARK: - Helpers

private extension WelcomeSection {
    var iconSize: CGFloat { FigmaSize.weightIconSmall.scaledToArtwork }

    /// Heading Small 20/30.
    var titleFont: UIFont {
        FontFace.firaSansSemiBold.font(size: FigmaSize.typographySizeHeadingSmall20.scaledToArtwork)
    }

    var titleLineHeight: CGFloat { FigmaSize.typographyLineHeightHeadingSmall20.scaledToArtwork }

    /// Display Small 14/21, sama dengan `bodyFont` dengan bobot semibold.
    var sectionFont: UIFont {
        FontFace.firaSansSemiBold.font(size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork)
    }

    /// Display Small 14/21.
    var bodyFont: UIFont {
        FontFace.openSansRegular.font(size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork)
    }

    var bodyLineHeight: CGFloat { FigmaSize.typographyLineHeightDisplaySmall14.scaledToArtwork }
}
