//
//  ScreenFooterPlacement.swift
//  DesignKit
//
//  Created by Wendra on 26/11/26.
//

/// Letak footer `ScreenScaffold` selama keyboard tampil.
enum ScreenFooterPlacement {
    /// Bawaan: naik di atas keyboard, mis. footer host dengan `TextField` biasa atau composer yang sedang diketik.
    case aboveKeyboard
    /// Tetap di bawah layar dan tertutup keyboard dari konten. Dikirim eksplisit oleh `MessageComposer` selama
    /// field-nya tidak diketik (mis. keyboard dibuka field form di daftar chat).
    case bottom
}
