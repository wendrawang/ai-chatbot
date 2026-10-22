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
    private let isEnabled: Bool
    private let onNewConversation: (() -> Void)?
    private let onSend: (String) -> Bool

    /// `onSend` mengembalikan true bila host menerima draft; false mempertahankannya di composer.
    public init(
        locale: Locale = .current, colors: any FigmaColorProtocol = EnvironmentValues().designColors,
        isEnabled: Bool = true, onNewConversation: (() -> Void)? = nil,
        onSend: @escaping (String) -> Bool
    ) {
        self.locale = locale
        self.colors = colors
        self.isEnabled = isEnabled
        self.onNewConversation = onNewConversation
        self.onSend = onSend
    }

    /// Halaman Tanya AI. Tanpa `onBack`, tombol kembali memakai `dismiss` SwiftUI (pop pada navigasi host).
    public func makeView(onBack: (() -> Void)? = nil) -> some View {
        makeView(onBack: onBack) { EmptyView() }
    }

    /// Sama seperti di atas, dengan konten SwiftUI untuk area scroll (fixture UI atau konten fitur).
    public func makeView<Content: View>(
        onBack: (() -> Void)? = nil, @ViewBuilder content: () -> Content
    ) -> some View {
        ChatScreen(
            isEnabled: isEnabled, onBack: onBack, onNewConversation: onNewConversation, onSend: onSend,
            content: content
        )
        .environment(\.locale, locale)
        .designColors(colors)
        // Starter mengikuti light palette Figma; dibatasi ke halaman ini, tidak mengubah host.
        .environment(\.colorScheme, .light)
    }
}
