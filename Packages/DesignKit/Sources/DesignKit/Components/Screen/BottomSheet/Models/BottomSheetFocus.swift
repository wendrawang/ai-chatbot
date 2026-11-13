//
//  BottomSheetFocus.swift
//  DesignKit
//
//  Created by Wendra on 13/11/26.
//

/// Penanda bagian isi sheet yang harus terlihat begitu isi mulai di-scroll, mis. pilihan yang sudah terpilih di
/// daftar panjang. Dipasang sebagai `.id(BottomSheetFocus.id)` pada satu view di dalam isi; `BottomSheet` lalu
/// menggulirnya ke tengah. Tanpa penanda, isi mulai dari atas.
enum BottomSheetFocus {
    static let id = ObjectIdentifier(BottomSheetFocus.self)
}
