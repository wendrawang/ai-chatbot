//
//  TanyaAIPage.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI
import TanyaAI

/// Membungkus halaman package untuk SwiftUI. Halaman dibuat sekali selama tampil.
@MainActor
struct TanyaAIPage: UIViewControllerRepresentable {
    let host: TanyaAIHost
    let onBack: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        host.makeViewController(onBack: onBack)
    }

    func updateUIViewController(_ controller: UIViewController, context: Context) {}
}
