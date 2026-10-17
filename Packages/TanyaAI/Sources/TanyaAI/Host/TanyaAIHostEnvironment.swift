//
//  TanyaAIHostEnvironment.swift
//  TanyaAI
//
//  Created by Wendra on 17/10/26.
//

import DesignKit
import SwiftUI

/// Locale dan palette terakhir dari root host. Fitur yang sedang terbuka mengamatinya,
/// sehingga ganti bahasa atau theme di host langsung terlihat tanpa membuka ulang.
@MainActor
final class TanyaAIHostEnvironment: ObservableObject {
    @Published
    private(set) var locale = Locale.current
    @Published
    private(set) var colors = EnvironmentValues().designColors
    private var pending: (locale: Locale, colors: any FigmaColorProtocol)?

    /// Dipanggil dari update anchor, yaitu di dalam pass render host. Publikasi ditunda
    /// ke luar pass itu agar tidak memicu "Publishing changes from within view updates".
    func receive(locale: Locale, colors: any FigmaColorProtocol) {
        pending = (locale, colors)
        DispatchQueue.main.async { [weak self] in self?.apply() }
    }

    /// Terapkan nilai terakhir sekarang; aman di luar view update, misalnya saat `present()`.
    func apply() {
        guard let pending else { return }
        self.pending = nil
        if locale != pending.locale { locale = pending.locale }
        if ObjectIdentifier(type(of: colors)) != ObjectIdentifier(type(of: pending.colors)) {
            colors = pending.colors
        }
    }
}

/// Memasang locale dan palette host ke seluruh screen fitur.
struct HostEnvironmentReader<Content: View>: View {
    @ObservedObject
    var environment: TanyaAIHostEnvironment
    let content: Content

    var body: some View {
        content
            .environment(\.locale, environment.locale)
            .designColors(environment.colors)
    }
}
