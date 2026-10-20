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

    /// Halaman siap di-push. Tanpa `onBack`, tombol kembali melakukan pop pada navigation controller host.
    public func makeViewController(onBack: (() -> Void)? = nil) -> UIViewController {
        makeViewController(onBack: onBack) { EmptyView() }
    }

    /// Sama seperti di atas, dengan konten SwiftUI untuk area scroll (fixture UI atau konten fitur).
    public func makeViewController<Content: View>(
        onBack: (() -> Void)? = nil, @ViewBuilder content: () -> Content
    ) -> UIViewController {
        weak var page: UIViewController?
        let screen = ChatScreen(
            isEnabled: isEnabled,
            onBack: {
                if let onBack { onBack() } else { page?.navigationController?.popViewController(animated: true) }
            },
            onNewConversation: onNewConversation, onSend: onSend, content: content
        )
        .environment(\.locale, locale)
        .designColors(colors)
        let controller = UIHostingController(rootView: screen)
        // Starter mengikuti light palette Figma; dibatasi ke halaman ini, tidak mengubah host.
        controller.overrideUserInterfaceStyle = .light
        page = controller
        return controller
    }
}
