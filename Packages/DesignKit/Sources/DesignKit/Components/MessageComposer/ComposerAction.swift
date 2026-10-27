//
//  ComposerAction.swift
//  DesignKit
//
//  Created by Wendra on 26/10/26.
//

/// Keadaan tombol aksi di samping field composer.
public enum ComposerAction: Equatable {
    /// Kirim draft; aktif bila draft berisi teks.
    case send
    /// Pesan sedang dikirim; tombol menampilkan titik bergerak dan tidak bisa ditekan.
    case sending
    /// Menunggu jawaban; tombol menghentikan jawaban.
    case stop
}
