//
//  ScreenFooterPlacement.swift
//  DesignKit
//
//  Created by Wendra on 26/11/26.
//

/// Letak footer `ScreenScaffold` selama keyboard tampil.
enum ScreenFooterPlacement {
    /// Tetap di bawah layar dan tertutup keyboard dari konten (mis. field form di daftar chat).
    case bottom
    /// Naik di atas keyboard karena input di dalam footer (mis. `MessageComposer`) sedang diketik.
    case aboveKeyboard
}
