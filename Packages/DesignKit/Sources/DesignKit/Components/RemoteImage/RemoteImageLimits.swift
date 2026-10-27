//
//  RemoteImageLimits.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

/// Batas teknis `RemoteImageLoader`: bukan token desain, jadi tidak di-scale.
enum RemoteImageLimits {
    /// Hanya respons HTTP 2xx yang dianggap gambar; 4xx/5xx (meski berisi gambar) dianggap gagal.
    static let successStatusCodes = 200..<300
    /// Anggaran memori bitmap hasil decode (byte) untuk seluruh cache; yang lama dilepas bila terlampaui.
    static let memoryCostLimit = 16 * 1024 * 1024
}
