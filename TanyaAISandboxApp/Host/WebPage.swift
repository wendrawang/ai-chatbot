//
//  WebPage.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 21/10/26.
//

import SwiftUI
import UIKit

/// Tiruan webview host untuk link web dari jawaban (bukan Safari), ditampilkan sebagai sheet.
@MainActor
struct WebPage: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: SandboxWebViewController(url: url))
    }

    func updateUIViewController(_ controller: UINavigationController, context: Context) {}
}
