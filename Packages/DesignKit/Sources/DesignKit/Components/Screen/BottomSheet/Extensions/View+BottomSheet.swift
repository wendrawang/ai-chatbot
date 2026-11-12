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
    /// dan lainnya). Menutup lewat ketuk latar gelap, geser ke bawah, atau `isPresented = false` dari pemakai.
    /// `closeLabel` = label aksesibilitas untuk menutup, dari copy pemakai.
    func bottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        closeLabel: String,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(BottomSheetPresenter(isPresented: isPresented, closeLabel: closeLabel, content: content))
    }
}
