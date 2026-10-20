//
//  TanyaAIDestination.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Tujuan link Tanya AI di base `Screen`. Dibungkus `Screen` agar blocker host ikut berlaku.
@MainActor
struct TanyaAIDestination: View {
    // StateObject: view model tetap sama walau halaman pemanggil render ulang.
    @StateObject
    private var viewModel = TanyaAIScreenViewModel()
    let presenterID: UUID

    var body: some View {
        Screen(isTanyaAIAvailable: false) {
            TanyaAIScreen(viewModel: viewModel, onBack: TanyaAIRouter.instance.close)
        }
        .onDisappear { TanyaAIRouter.instance.didDisappear(from: presenterID) }
    }
}
