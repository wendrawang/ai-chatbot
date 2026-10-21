//
//  TanyaAIHost.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI
import UIKit

/// Konfigurasi dan pembuat halaman Tanya AI. Host mem-push `makeViewController()` ke
/// navigation controller miliknya; navigasi, animasi dan swipe-back sepenuhnya bawaan UIKit.
/// `locale` dan `colors` dibaca saat halaman dibuat, jadi perubahan berlaku saat dibuka berikutnya.
@MainActor
public struct TanyaAIHost {
    /// Bahasa fitur, misalnya dari Localize_Swift milik host.
    public var locale: Locale
    /// Palette fitur dari hasil inquiry proposition; sebelum itu memakai palette default.
    public var colors: any FigmaColorProtocol
    private let customerName: String
    private let service: TanyaAIService
    private let onOpenLink: (TanyaAILink) -> Void

    /// - Parameters:
    ///   - customerName: nama pada sapaan welcome ("Hi, Lara Croft!").
    ///   - service: SSE chat dan inquiry BE milik host.
    ///   - onOpenLink: link dari jawaban; host membuka webview, deeplink, atau telepon.
    public init(
        customerName: String, service: TanyaAIService, locale: Locale = .current,
        colors: any FigmaColorProtocol = EnvironmentValues().designColors,
        onOpenLink: @escaping (TanyaAILink) -> Void
    ) {
        self.locale = locale
        self.colors = colors
        self.customerName = customerName
        self.service = service
        self.onOpenLink = onOpenLink
    }

    /// Halaman baru dengan percakapan baru. Tanpa `onBack`, tombol kembali melakukan pop
    /// pada navigation controller host.
    public func makeViewController(onBack: (() -> Void)? = nil) -> UIViewController {
        weak var page: UIViewController?
        let viewModel = ChatViewModel(service: service, locale: locale, onOpenLink: onOpenLink)
        let screen = ChatScreen(viewModel: viewModel, customerName: customerName) {
            if let onBack { onBack() } else { page?.navigationController?.popViewController(animated: true) }
        }
        let controller = UIHostingController(rootView: applyingSettings(to: screen))
        // Starter mengikuti light palette Figma; dibatasi ke halaman ini, tidak mengubah host.
        controller.overrideUserInterfaceStyle = .light
        page = controller
        return controller
    }

    /// Bahasa dan palette host untuk seluruh isi halaman baru.
    func applyingSettings<Content: View>(to content: Content) -> some View {
        content
            .environment(\.locale, locale)
            .designColors(colors)
    }
}
