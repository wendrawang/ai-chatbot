//
//  TanyaAIScreen.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Konten halaman Tanya AI di host.
@MainActor
struct TanyaAIScreen: ScreenContent {
    @ObservedObject
    var viewModel: TanyaAIScreenViewModel
    let onBack: () -> Void

    var body: some View {
        TanyaAIPage(host: viewModel.makeHost(), onBack: onBack)
            .ignoresSafeArea()
    }
}
