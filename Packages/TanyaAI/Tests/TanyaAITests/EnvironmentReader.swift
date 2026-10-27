//
//  EnvironmentReader.swift
//  TanyaAI
//
//  Created by Wendra on 18/10/26.
//

import DesignKit
import SwiftUI

/// Melaporkan palette dan bahasa yang sampai ke isi halaman.
struct EnvironmentReader: View {
    @Environment(\.designColors)
    private var colors
    @Environment(\.locale)
    private var locale
    let onRead: (any FigmaColorProtocol, Locale) -> Void

    var body: some View {
        onRead(colors, locale)
        return Text("Content")
    }
}
