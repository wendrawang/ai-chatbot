//
//  TanyaAIScreen.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Konten halaman Tanya AI di host: view SwiftUI dari package, tanpa pembungkus UIKit.
@MainActor
struct TanyaAIScreen: ScreenContent {
    @ObservedObject
    var viewModel: TanyaAIScreenViewModel
    let onBack: () -> Void

    var body: some View {
        viewModel.makeHost().makeView(onBack: onBack)
    }
}
