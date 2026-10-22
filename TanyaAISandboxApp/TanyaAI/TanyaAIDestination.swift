//
//  TanyaAIDestination.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Pemilik view model halaman Tanya AI. `@StateObject` dibuat sekali saat halaman di-push dan
/// dilepas saat di-pop; render ulang halaman induk tidak membuatnya ulang.
@MainActor
struct TanyaAIDestination: View {
    @StateObject
    private var viewModel = TanyaAIScreenViewModel()
    let onBack: () -> Void

    var body: some View {
        Screen {
            TanyaAIScreen(viewModel: viewModel, onBack: onBack)
        }
    }
}
