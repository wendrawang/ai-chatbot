//
//  OptionSelection.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

/// Pilihan yang sedang dicentang di `OptionList`, sebelum dikembalikan ke pemakai.
struct OptionSelection: Equatable {
    let mode: OptionSelectionMode
    private(set) var selectedIDs: Set<String>

    init(mode: OptionSelectionMode, selectedIDs: [String]) {
        self.mode = mode
        self.selectedIDs = Set(selectedIDs)
    }

    func isSelected(_ id: String) -> Bool {
        selectedIDs.contains(id)
    }

    /// Ketukan pada satu pilihan. True = pilihan selesai dan bisa dikembalikan ke pemakai (hanya mode `single`); mode
    /// `multiple` menyalakan atau mematikan centangnya dan menunggu tombol konfirmasi.
    mutating func toggle(_ id: String) -> Bool {
        guard mode == .multiple else {
            selectedIDs = [id]
            return true
        }
        if selectedIDs.remove(id) == nil {
            selectedIDs.insert(id)
        }
        return false
    }

    /// Tombol konfirmasi hanya menghitung centang yang masih ada di daftar terbaru, sama dengan hasil `ordered(in:)`,
    /// supaya id lama yang sudah hilang dari daftar tidak membuat tombol aktif dengan hasil kosong.
    func isConfirmable(in items: [OptionItem], isEmptyAllowed: Bool) -> Bool {
        isEmptyAllowed || !ordered(in: items).isEmpty
    }

    /// Urut sesuai daftar, bukan urutan ketukan, supaya hasilnya sama walau nasabah mencentang acak.
    func ordered(in items: [OptionItem]) -> [String] {
        items.map(\.id).filter(selectedIDs.contains)
    }
}
