//
//  PaletteReader.swift
//  DesignKitTests
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

@testable import DesignKit

/// Melaporkan palette yang sampai ke posisinya di pohon view, setiap kali dirender.
struct PaletteReader: View {
    @Environment(\.designColors) private var colors
    let onRead: (any FigmaColorProtocol) -> Void

    var body: some View {
        onRead(colors)
        return Color.clear.frame(width: 1, height: 1)
    }
}
