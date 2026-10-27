//
//  DetailScreen.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import DesignKit
import SwiftUI

/// Halaman host level kedua; membuka Tanya AI lewat coordinator miliknya sendiri.
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
    let onOpenTanyaAI: () -> Void

    var body: some View {
        VStack(spacing: FigmaSize.spacingLarge.scaledToArtwork) {
            ScreenHeader(
                title: String(SandboxCopy.detailTitle, locale: locale),
                backLabel: String(SandboxCopy.back, locale: locale),
                isScrolled: false, onBack: { dismiss() }
            )
            HostButton(
                title: String(SandboxCopy.open, locale: locale),
                identifier: SandboxOptions.detailTanyaAIIdentifier, action: onOpenTanyaAI
            )
            Spacer()
        }
        .background(colors.colorsSurfacePrimary.ignoresSafeArea())
    }
}
