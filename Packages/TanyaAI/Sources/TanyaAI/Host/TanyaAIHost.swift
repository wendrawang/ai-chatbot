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
    private let service: TanyaAIService
    private let onNewConversation: (() -> Void)?

    /// - Parameters:
    ///   - service: jaringan milik host (init, history, stream SSE, kirim chat).
    ///   - onNewConversation: aksi menu "Percakapan baru"; tanpa handler, item menu disabled.
    public init(
        locale: Locale = .current, colors: any FigmaColorProtocol = EnvironmentValues().designColors,
        service: TanyaAIService, onNewConversation: (() -> Void)? = nil
    ) {
        self.locale = locale
        self.colors = colors
        self.service = service
        self.onNewConversation = onNewConversation
    }

    /// Halaman Tanya AI. Tanpa `onBack`, tombol kembali memakai `dismiss` SwiftUI (pop pada navigasi host).
    /// `ChatViewModel` dibuat sekali per halaman (`@StateObject`), walau view ini dievaluasi ulang
    /// setiap host render; sesi dan stream dibuka saat halaman tampil.
    public func makeView(onBack: (() -> Void)? = nil) -> some View {
        applyingSettings(
            to: ChatScreen(
                viewModel: ChatViewModel(service: service), onBack: onBack, onNewConversation: onNewConversation
            )
        )
    }

    /// Bahasa dan palette host untuk seluruh isi halaman.
    func applyingSettings<Content: View>(to content: Content) -> some View {
        content
            .environment(\.locale, locale)
            .designColors(colors)
            // Starter mengikuti light palette Figma; dibatasi ke halaman ini, tidak mengubah host.
            .environment(\.colorScheme, .light)
    }
}
