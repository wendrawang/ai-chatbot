//
//  MainScreen.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import DesignKit
import SwiftUI

/// Tiruan main host: Tanya AI dibuka dari mana saja lewat `TanyaAIRouter`.
@MainActor
struct MainScreen: ScreenContent {
    @Environment(\.locale)
    private var locale
    @Environment(\.designColors)
    private var colors
    @EnvironmentObject
    private var appState: AppState
    @ObservedObject
    var viewModel: MainScreenViewModel
    let onOpenDetail: () -> Void

    var body: some View {
        VStack(spacing: FigmaSize.spacingLarge.scaledToArtwork) {
            Text(String(resource: R.string.localizable.sandboxMainTitle, locale: locale))
                .font(
                    Font(FontFace.firaSansSemiBold.font(size: FigmaSize.typographySizeDisplayNormal16.scaledToArtwork)))
            actions
        }
        .foregroundColor(colors.colorsTextPrimaryDark)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.colorsSurfacePrimary.ignoresSafeArea())
    }

    @ViewBuilder
    private var actions: some View {
        HostButton(
            title: String(resource: R.string.localizable.sandboxOpen, locale: locale),
            identifier: SandboxOptions.openIdentifier, action: TanyaAIRouter.instance.open
        )
        HostButton(
            title: String(resource: R.string.localizable.sandboxDetailOpen, locale: locale),
            identifier: SandboxOptions.detailOpenIdentifier, action: onOpenDetail
        )
        HostButton(
            title: String(resource: R.string.localizable.sandboxOfflineSimulate, locale: locale),
            identifier: SandboxOptions.offlineSimulateIdentifier
        ) { viewModel.didReceiveError(URLError(.notConnectedToInternet)) }
        HostButton(
            title: String(resource: R.string.localizable.sandboxLogout, locale: locale),
            identifier: SandboxOptions.logoutIdentifier
        ) { appState.state = .prelogin }
    }
}
