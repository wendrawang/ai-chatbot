//
//  TanyaAITermsScreen.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 26/10/26.
//

import DesignKit
import SwiftUI

/// Halaman T&C milik host sebelum Tanya AI pertama kali dibuka. Isi T&C dari BE.
@MainActor
struct TanyaAITermsScreen: ScreenContent {
    @Environment(\.locale)
    private var locale
    @Environment(\.designColors)
    private var colors
    @ObservedObject
    var viewModel: TanyaAITermsViewModel
    let onBack: () -> Void

    var body: some View {
        ScreenContainer(
            title: String(resource: R.string.localizable.sandboxTermsTitle, locale: locale),
            backLabel: String(resource: R.string.localizable.sandboxBack, locale: locale), onBack: onBack,
            content: { content }, trailing: { EmptyView() }, footer: { footer }
        )
        .onAppear(perform: viewModel.load)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
        case .loaded(let terms):
            VStack(alignment: .leading, spacing: FigmaSize.spacingMedium.scaledToArtwork) {
                ForEach(terms.paragraphs, id: \.self) { paragraph in
                    Text(paragraph)
                        .foregroundColor(colors.colorsTextPrimaryDark)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        case .failed:
            // Blocker host menutupi halaman; tombol coba lagi-nya mengulang inquiry.
            EmptyView()
        }
    }

    private var footer: some View {
        HostButton(
            title: String(resource: R.string.localizable.sandboxTermsAccept, locale: locale),
            identifier: SandboxOptions.termsAcceptIdentifier, action: viewModel.accept
        )
        .disabled(!isAcceptEnabled)
        .padding(FigmaSize.spacingLarge.scaledToArtwork)
    }

    private var isAcceptEnabled: Bool {
        guard case .loaded = viewModel.phase else { return false }
        return !viewModel.isAccepting
    }
}
