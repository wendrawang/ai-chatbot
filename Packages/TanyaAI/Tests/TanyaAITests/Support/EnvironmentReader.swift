//
//  EnvironmentReader.swift
//  TanyaAITests
//
//  Created by Wendra on 12/11/26.
//

import DesignKit
import SwiftUI

/// Melaporkan palette dan locale yang sampai ke konten sisipan, setiap kali dirender.
struct EnvironmentReader: View {
    @Environment(\.designColors) private var colors
    @Environment(\.locale) private var locale
    let onRead: (any FigmaColorProtocol, Locale) -> Void

    var body: some View {
        onRead(colors, locale)
        return Text("Content")
    }
}
