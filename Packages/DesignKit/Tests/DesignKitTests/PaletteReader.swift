//
//  PaletteReader.swift
//  DesignKit
//
//  Created by Wendra on 17/10/26.
//

import SwiftUI

@testable import DesignKit

/// Melaporkan palette yang sampai ke view ini.
struct PaletteReader: View {
    @Environment(\.designColors)
    private var colors
    let onRead: (any FigmaColorProtocol) -> Void

    var body: some View {
        onRead(colors)
        return Color.clear.frame(width: 1, height: 1)
    }
}
