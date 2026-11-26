//
//  ScreenScaffold.swift
//  DesignKit
//
//  Created by Wendra on 5/11/26.
//

import SwiftUI

/// Kerangka halaman: header menimpa area konten, footer di bawahnya, dan latar di belakang semuanya. Scroll milik
/// konten, jadi pemilik scroll (mis. table) melaporkan `scrollProgress`. `content` menerima tinggi header supaya
/// bisa memberi inset awal. Footer hanya naik di atas keyboard bila input di dalamnya yang diketik
/// (`ScreenFooterPlacementKey`); keyboard dari konten (mis. field form di daftar chat) menutupi footer, dan konten
/// berakhir tepat di atas keyboard.
@MainActor
public struct ScreenScaffold<Content: View, Trailing: View, Footer: View, Background: View>: View {
    @Environment(\.designColors) private var colors
    @State private var footerPlacement = ScreenFooterPlacement.bottom
    /// Tepi atas footer di koordinat layar; tak hingga sampai terukur.
    @State private var footerTop = CGFloat.infinity
    private let title: String
    private let backLabel: String
    private let scrollProgress: CGFloat
    private let onBack: () -> Void
    private let content: (CGFloat) -> Content
    private let trailing: Trailing
    private let footer: Footer
    private let background: Background

    public init(
        title: String, backLabel: String, scrollProgress: CGFloat, onBack: @escaping () -> Void,
        @ViewBuilder content: @escaping (CGFloat) -> Content, @ViewBuilder trailing: () -> Trailing,
        @ViewBuilder footer: () -> Footer, @ViewBuilder background: () -> Background
    ) {
        self.title = title
        self.backLabel = backLabel
        self.scrollProgress = scrollProgress
        self.onBack = onBack
        self.content = content
        self.trailing = trailing()
        self.footer = footer()
        self.background = background()
    }

    public var body: some View {
        // Safe area atas dibaca sekali di root; header dan konten sendiri mulai dari tepi atas layar.
        // Wadah ini mengecil oleh keyboard; konten berakhir di atas keyboard atau footer, mana yang lebih tinggi.
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                surface(isNotched: ScreenHeader.isNotched(safeAreaTop: geometry.safeAreaInsets.top))
                    .padding(
                        .bottom,
                        Self.footerOverlap(bottom: geometry.frame(in: .global).maxY, footerTop: footerTop)
                    )
                footerLayer
            }
        }
        .background(backdrop)
    }

    /// Lapisan setinggi layar agar footer menempel di bawah; tetap di bawah (tertutup keyboard) selama input footer
    /// tidak diketik. Spacer tidak menangkap sentuhan, jadi konten di belakangnya tetap bisa disentuh.
    private var footerLayer: some View {
        VStack(spacing: .zero) {
            Spacer(minLength: .zero)
            footer
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: ScreenFooterTopKey.self, value: proxy.frame(in: .global).minY)
                    }
                )
        }
        .ignoresSafeArea(.keyboard, edges: footerPlacement == .aboveKeyboard ? [] : .bottom)
        .onPreferenceChange(ScreenFooterTopKey.self) { footerTop = $0 }
        .onPreferenceChange(ScreenFooterPlacementKey.self) { footerPlacement = $0 }
    }

    private var backdrop: some View {
        ZStack {
            colors.colorsSurfacePrimary
            background
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func surface(isNotched: Bool) -> some View {
        ZStack(alignment: .top) {
            content(ScreenHeader.height(isNotched: isNotched))
            ScreenHeader(
                title: title, backLabel: backLabel, scrollProgress: scrollProgress, isNotched: isNotched,
                onBack: onBack, trailing: { trailing }
            )
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}

// MARK: - Helpers

extension ScreenScaffold {
    /// Jarak bawah konten: bagian wadah (yang sudah dikecilkan keyboard) di bawah tepi atas footer. Nol bila footer
    /// tertutup keyboard, jadi konten berakhir tepat di atas keyboard.
    static func footerOverlap(bottom: CGFloat, footerTop: CGFloat) -> CGFloat {
        max(.zero, bottom - footerTop)
    }
}
