//
//  OptionSelectionMode.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

/// Cara memilih di `OptionList`.
public enum OptionSelectionMode: Equatable {
    /// Radio: satu ketukan langsung menjadi pilihan dan daftar selesai.
    case single
    /// Centang: boleh lebih dari satu, selesai lewat tombol konfirmasi.
    case multiple
}
