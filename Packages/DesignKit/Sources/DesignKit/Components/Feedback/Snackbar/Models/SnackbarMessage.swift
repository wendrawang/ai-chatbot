//
//  SnackbarMessage.swift
//  DesignKit
//
//  Created by Wendra on 26/11/26.
//

import Foundation

/// Isi satu `Snackbar`. Setiap pesan punya id sendiri, jadi pesan yang sama berturut-turut tetap kejadian baru dan
/// tampil penuh lagi.
public struct SnackbarMessage: Equatable {
    public let id = UUID()
    public let text: String
    public let tone: ActionBannerTone

    /// `text` sudah dilokalkan pemakai; `tone` menentukan warna, mis. `.warning` untuk penolakan.
    public init(text: String, tone: ActionBannerTone) {
        self.text = text
        self.tone = tone
    }
}
