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
    private let customerName: String
    private let service: TanyaAIService
    private let onOpenLink: (TanyaAILink) -> Void
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

    /// - Parameters:
    ///   - customerName: nama pada sapaan welcome ("Hi, Lara Croft!").
    ///   - service: SSE chat dan inquiry BE milik host.
    ///   - onOpenLink: link dari jawaban; host membuka webview, deeplink, atau telepon.
    public init(
        customerName: String, service: TanyaAIService, locale: Locale = .current,
        colors: any FigmaColorProtocol = EnvironmentValues().designColors,
        onOpenLink: @escaping (TanyaAILink) -> Void
    ) {
        self.customerName = customerName
        self.service = service
        self.onOpenLink = onOpenLink
        hostEnvironment = TanyaAIHostEnvironment(locale: locale, colors: colors)
    }

    /// Halaman baru dengan percakapan baru. Tanpa `onBack`, tombol kembali melakukan pop
    /// pada navigation controller host.
    public func makeViewController(onBack: (() -> Void)? = nil) -> UIViewController {
        weak var page: UIViewController?
        let environment = hostEnvironment
        let viewModel = ChatViewModel(
            service: service, locale: { [weak environment] in environment?.locale ?? .current }, onOpenLink: onOpenLink
        )
        let screen = HostEnvironmentReader(
            environment: hostEnvironment,
            content: ChatScreen(viewModel: viewModel, customerName: customerName) {
                if let onBack { onBack() } else { page?.navigationController?.popViewController(animated: true) }
            }
        )
        let controller = UIHostingController(rootView: screen)
        // Starter mengikuti light palette Figma; dibatasi ke halaman ini, tidak mengubah host.
        controller.overrideUserInterfaceStyle = .light
        page = controller
        return controller
    }
}
