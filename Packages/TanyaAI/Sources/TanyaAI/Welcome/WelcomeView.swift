//
//  WelcomeView.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import DesignKit
import SwiftUI

/// Tampilan awal: logo, sapaan nasabah, dan shortcut "Mulai dari sini".
@MainActor
struct WelcomeView: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.designColors)
    private var colors
    let customerName: String
    let topInset: CGFloat
    let onSelect: (QuickAction) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                greeting
                shortcuts.padding(.top, FigmaSize.spacingExtraLarge.scaledToArtwork)
            }
            .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
            .padding(.top, topInset + FigmaSize.spacingExtraLarge.scaledToArtwork)
            .padding(.bottom, FigmaSize.spacingLarge.scaledToArtwork)
        }
        .accessibilityIdentifier(ChatElementIdentifier.welcome)
    }

    private var greeting: some View {
        VStack(spacing: .zero) {
            Image(R.image.emblem).resizable().scaledToFit()
                .frame(
                    width: CustomSizes.Welcome.emblem.scaledToArtwork,
                    height: CustomSizes.Welcome.emblem.scaledToArtwork
                )
                .accessibilityHidden(true)
            Text(String(format: R.string.localizable.welcomeGreeting, locale: locale, customerName))
                .font(FontFace.firaSansSemiBold.scaledFont(size: FigmaSize.typographySizeHeadingSmall20))
                .foregroundColor(colors.colorsTextPrimaryDark)
                .padding(.top, FigmaSize.spacingLarge.scaledToArtwork)
            Text(String(resource: R.string.localizable.welcomeDescription, locale: locale))
                .font(FontFace.firaSansRegular.scaledFont(size: FigmaSize.typographySizeDisplaySmall14))
                .foregroundColor(colors.colorsTextSecondary)
                .padding(.top, FigmaSize.spacingSmall.scaledToArtwork)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var shortcuts: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacingMedium.scaledToArtwork) {
            HStack(spacing: FigmaSize.spacingSmall.scaledToArtwork) {
                Image(DesignKit.R.image.lightbulb).resizable().scaledToFit()
                    .frame(
                        width: FigmaSize.weightIconSmall.scaledToArtwork,
                        height: FigmaSize.weightIconSmall.scaledToArtwork
                    )
                    .foregroundColor(colors.colorsIconColored)
                Text(String(resource: R.string.localizable.welcomeStart, locale: locale))
                    .font(FontFace.firaSansSemiBold.scaledFont(size: FigmaSize.typographySizeDisplaySmall14))
                    .foregroundColor(colors.colorsTextPrimaryDark)
            }
            ForEach(QuickAction.allCases) { action in
                QuickActionRow(
                    icon: action.icon, title: action.title(locale: locale), subtitle: action.subtitle(locale: locale)
                ) { onSelect(action) }
            }
        }
    }
}
