//
//  TanyaAIHost.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI

/// Konfigurasi dan pembuat halaman Tanya AI dalam SwiftUI. Host menampilkan `makeView()` lewat
/// navigasinya sendiri, misalnya sebagai tujuan `NavigationLink`; halaman berikutnya milik host.
/// `locale` dan `colors` dibaca saat view dibuat, jadi perubahan berlaku saat dibuka berikutnya.
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

    /// Halaman dengan percakapan baru. Tanpa `onBack`, tombol kembali memakai `dismiss` SwiftUI.
    /// `ChatViewModel` dibuat sekali per halaman (`@StateObject` di `ChatScreen`), walau view ini
    /// dievaluasi ulang setiap host render.
    public func makeView(onBack: (() -> Void)? = nil) -> some View {
        applyingSettings(
            to: ChatScreen(
                viewModel: ChatViewModel(service: service, locale: locale, onOpenLink: onOpenLink),
                customerName: customerName, onBack: onBack
            )
        )
    }

    /// Bahasa dan palette host untuk seluruh isi halaman baru.
    func applyingSettings<Content: View>(to content: Content) -> some View {
        content
            .environment(\.locale, locale)
            .designColors(colors)
            // Starter mengikuti light palette Figma; dibatasi ke halaman ini, tidak mengubah host.
            .environment(\.colorScheme, .light)
    }
}
