//
//  MessageRowContent.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import DesignKit
import SwiftUI

/// Isi cell daftar. Cell UIKit tidak mewarisi environment SwiftUI, jadi locale dan palette
/// dipasang ulang di sini.
struct MessageRowContent: View {
    let row: MessageRowKind
    let handlers: MessageHandlers
    let locale: Locale
    let colors: any FigmaColorProtocol

    var body: some View {
        MessageRow(kind: row, handlers: handlers)
            .environment(\.locale, locale)
            .designColors(colors)
    }
}
