//
//  DetailScreen.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import DesignKit
import SwiftUI

/// Halaman host level kedua; membuktikan Tanya AI terbuka dari mana saja tanpa didaftarkan.
@MainActor
struct DetailScreen: ScreenContent {
    @Environment(\.locale)
    private var locale
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.designColors)
    private var colors
    @ObservedObject
    var viewModel: DetailScreenViewModel

    var body: some View {
        VStack(spacing: FigmaSize.spacingLarge.scaledToArtwork) {
            ScreenHeader(
                title: String(resource: R.string.localizable.sandboxDetailTitle, locale: locale),
                backLabel: String(resource: R.string.localizable.sandboxBack, locale: locale),
                isScrolled: false, onBack: { dismiss() }
            )
            HostButton(
                title: String(resource: R.string.localizable.sandboxOpen, locale: locale),
                identifier: SandboxOptions.detailTanyaAIIdentifier, action: TanyaAIRouter.instance.open
            )
            Spacer()
        }
        .background(colors.colorsSurfacePrimary.ignoresSafeArea())
    }
}
