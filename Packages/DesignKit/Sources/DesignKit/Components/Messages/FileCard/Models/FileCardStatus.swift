//
//  FileCardStatus.swift
//  DesignKit
//
//  Created by Wendra on 27/11/26.
//

/// Keadaan file pada `FileCard`. Copy dari pemakai; DesignKit hanya menentukan tampilannya. Setiap status hanya
/// mengganti isi baris kedua dan kotak ikon, jadi tinggi kartu tetap sama saat status berganti.
public enum FileCardStatus: Equatable {
    /// Sedang diproses (mis. dikirim): spinner di kotak ikon, kartu tidak bisa diketuk.
    case sending(note: String)
    /// Siap: keterangan (mis. format file) lalu aksi kartu (mis. lihat detail).
    case ready(note: String, action: String)
    /// Gagal: keterangan merah lalu aksi kartu (mis. coba lagi), dengan garis tepi merah.
    case failed(note: String, action: String)

    var note: String {
        switch self {
        case .sending(let note), .ready(let note, _), .failed(let note, _):
            return note
        }
    }

    /// Nil selama diproses: tidak ada aksi yang bisa dilakukan.
    var action: String? {
        switch self {
        case .sending:
            return nil
        case .ready(_, let action), .failed(_, let action):
            return action
        }
    }

    var isSending: Bool {
        guard case .sending = self else { return false }
        return true
    }

    var isFailed: Bool {
        guard case .failed = self else { return false }
        return true
    }
}
