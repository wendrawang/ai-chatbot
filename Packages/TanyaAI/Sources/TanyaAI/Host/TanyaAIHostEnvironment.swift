//
//  TanyaAIHostEnvironment.swift
//  TanyaAI
//
//  Created by Wendra on 17/10/26.
//

import DesignKit
import SwiftUI

/// Bahasa dan palette yang diisi host lewat `TanyaAIHost.locale/colors`.
/// Fitur yang sedang terbuka mengamatinya, jadi perubahan langsung terlihat tanpa membuka ulang.
@MainActor
final class TanyaAIHostEnvironment: ObservableObject {
    @Published
    var locale: Locale
    @Published
    var colors: any FigmaColorProtocol

    init(locale: Locale, colors: any FigmaColorProtocol) {
        self.locale = locale
        self.colors = colors
    }
}

/// Memasang bahasa dan palette host ke seluruh screen fitur.
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
