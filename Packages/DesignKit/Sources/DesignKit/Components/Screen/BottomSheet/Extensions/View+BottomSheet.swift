//
//  View+BottomSheet.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

public extension View {
    /// Bottom sheet di atas seluruh view ini; pasang di root halaman supaya header dan composer ikut tertutup latar
    /// gelap. Tinggi sheet mengikuti `content`, yang membawa judul dan padding-nya sendiri (daftar pilihan, keypad,
    /// dan lainnya). Isi yang lebih panjang dari `maxHeight` membuat sheet berhenti di sana dan isinya di-scroll;
    /// batas bawaan tepat di bawah status bar, `.screenFraction(0.6)` = paling tinggi 60% layar. Menutup lewat ketuk
    /// latar gelap, geser ke bawah, atau `isPresented = false` dari pemakai. `closeLabel` = label aksesibilitas untuk
    /// menutup, dari copy pemakai. Isi tidak boleh punya scroll vertikal sendiri (sheet yang menggulirnya) dan
    /// belum boleh berisi field yang membuka keyboard: sheet tidak naik mengikuti keyboard.
    func bottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        closeLabel: String,
        maxHeight: BottomSheetMaxHeight = .belowStatusBar,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(
            BottomSheetPresenter(
                isPresented: isPresented,
                closeLabel: closeLabel,
                maxHeight: maxHeight,
                content: content
            )
        )
    }

    /// Versi berbasis nilai, untuk halaman yang punya beberapa jenis sheet: sheet tampil selama `item` tidak nil dan
    /// isinya dibangun dari nilai itu, biasanya enum jenis sheet. Menutup sheet mengosongkan `item`. Nilai lain =
    /// isi baru, jadi state di dalam isi (mis. centang sementara `OptionList`) tidak terbawa dari sheet sebelumnya.
    /// Satu pemasangan di root halaman cukup untuk semua sheet halaman itu.
    func bottomSheet<Item: Hashable, SheetContent: View>(
        item: Binding<Item?>,
        closeLabel: String,
        maxHeight: BottomSheetMaxHeight = .belowStatusBar,
        @ViewBuilder content: @escaping (Item) -> SheetContent
    ) -> some View {
        bottomSheet(isPresented: item.isPresent(), closeLabel: closeLabel, maxHeight: maxHeight) {
            if let value = item.wrappedValue {
                content(value).id(value)
            }
        }
    }
}
