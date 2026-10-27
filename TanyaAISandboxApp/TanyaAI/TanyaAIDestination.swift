//
//  TanyaAIDestination.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Pemilik view model halaman Tanya AI. `@StateObject` dibuat sekali saat halaman di-push dan
/// dilepas saat di-pop; render ulang halaman induk tidak membuatnya ulang.
/// T&C tampil lebih dulu bila belum disetujui; setelah disetujui, halaman yang sama berganti ke chat
/// tanpa push baru, jadi back tetap kembali ke halaman sebelum Tanya AI.
@MainActor
struct TanyaAIDestination: View {
    @StateObject
    private var termsViewModel = TanyaAITermsViewModel()
    @StateObject
    private var viewModel = TanyaAIScreenViewModel()
    let onBack: () -> Void

    var body: some View {
        if termsViewModel.isAccepted {
            Screen {
                TanyaAIScreen(viewModel: viewModel, onBack: onBack)
            }
        } else {
            Screen {
                TanyaAITermsScreen(viewModel: termsViewModel, onBack: onBack)
            }
        }
    }
}
