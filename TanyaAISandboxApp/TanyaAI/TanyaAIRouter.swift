//
//  TanyaAIRouter.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Membuka Tanya AI dari layar mana pun. Router memilih `Screen` yang sedang tampil, lalu
/// link milik halaman itu yang melakukan push, sehingga stack tetap dimiliki SwiftUI.
@MainActor
final class TanyaAIRouter: ObservableObject {
    static let instance = TanyaAIRouter()

    @Published
    private(set) var presenterID: UUID?
    private var visibleScreenID: UUID?

    /// Diabaikan bila Tanya AI sudah terbuka atau tidak ada `Screen` yang tampil.
    func open() {
        guard presenterID == nil, let visibleScreenID else { return }
        presenterID = visibleScreenID
    }

    func close() {
        presenterID = nil
    }

    func screenDidAppear(_ screenID: UUID) {
        visibleScreenID = screenID
    }

    func screenDidDisappear(_ screenID: UUID) {
        if visibleScreenID == screenID { visibleScreenID = nil }
    }

    /// SwiftUI bisa mem-pop beberapa halaman sekaligus tanpa memanggil setter binding;
    /// halaman Tanya AI yang hilang selalu melepas status terbuka.
    func didDisappear(from screenID: UUID) {
        if presenterID == screenID { presenterID = nil }
    }

    func isPresented(from screenID: UUID) -> Binding<Bool> {
        Binding(
            get: { [weak self] in self?.presenterID == screenID },
            set: { [weak self] isActive in
                if !isActive { self?.didDisappear(from: screenID) }
            }
        )
    }
}
