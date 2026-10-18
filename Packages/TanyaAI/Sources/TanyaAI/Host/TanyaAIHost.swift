//
//  TanyaAIHost.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI
import UIKit

/// Konfigurasi dan pembuat halaman Tanya AI. Simpan satu instance di session main host,
/// lalu push `makeViewController()` ke navigation controller milik host.
/// Navigasi, animasi dan swipe-back sepenuhnya bawaan UIKit milik host.
@MainActor
public final class TanyaAIHost {
    private let isEnabled: Bool
    private let onNewConversation: (() -> Void)?
    private let onSend: (String) -> Bool
    private let hostEnvironment: TanyaAIHostEnvironment

    /// Bahasa fitur. Isi dari setting bahasa host (mis. Localize_Swift) setiap kali berubah;
    /// halaman yang sedang tampil langsung mengikuti tanpa kehilangan draft.
    public var locale: Locale {
        get { hostEnvironment.locale }
        set { hostEnvironment.locale = newValue }
    }

    /// Palette fitur. Isi dari hasil inquiry proposition; sebelum itu memakai palette default.
    public var colors: any FigmaColorProtocol {
        get { hostEnvironment.colors }
        set { hostEnvironment.colors = newValue }
    }

    /// `onSend` mengembalikan true bila host menerima draft; false mempertahankannya di composer.
    public init(
        locale: Locale = .current, colors: any FigmaColorProtocol = EnvironmentValues().designColors,
        isEnabled: Bool = true, onNewConversation: (() -> Void)? = nil,
        onSend: @escaping (String) -> Bool
    ) {
        hostEnvironment = TanyaAIHostEnvironment(locale: locale, colors: colors)
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
        let screen = HostEnvironmentReader(
            environment: hostEnvironment,
            content: ChatScreen(
                isEnabled: isEnabled,
                onBack: {
                    if let onBack { onBack() } else { page?.navigationController?.popViewController(animated: true) }
                },
                onNewConversation: onNewConversation, onSend: onSend, content: content
            )
        )
        let controller = UIHostingController(rootView: screen)
        // Starter mengikuti light palette Figma; dibatasi ke halaman ini, tidak mengubah host.
        controller.overrideUserInterfaceStyle = .light
        page = controller
        return controller
    }
}
