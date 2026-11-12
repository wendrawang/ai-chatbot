//
//  FontLoaderFailure.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import Foundation

/// Kegagalan `FontLoader` saat mendaftarkan font.
public enum FontLoaderFailure: Error {
    /// File font tidak ada di bundle.
    case missingResource(String)
    /// File ada tetapi bukan font yang bisa dibaca.
    case invalidFont(URL)
    /// CoreText menolak pendaftaran (selain karena sudah terdaftar).
    case registration(URL)
}
