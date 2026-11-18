//
//  ChatAttachmentSource.swift
//  TanyaAI
//
//  Created by Wendra on 18/11/26.
//

/// Asal lampiran yang dipilih nasabah dari tombol `+` composer. Kamera sengaja tidak ada (keputusan user).
enum ChatAttachmentSource: Identifiable {
    /// Galeri foto sistem: satu gambar HEIC, JPG/JPEG, atau PNG.
    case gallery
    /// Aplikasi Files: PDF atau gambar dengan format yang sama.
    case file

    var id: Self { self }
}
