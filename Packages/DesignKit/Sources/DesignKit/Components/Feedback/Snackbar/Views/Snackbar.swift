//
//  Snackbar.swift
//  DesignKit
//
//  Created by Wendra on 26/11/26.
//

import SwiftUI

/// Pemberitahuan singkat tanpa tombol untuk error/warning yang tidak butuh tindakan. Tampil sebagai `ActionBanner`
/// sesuai tone pesan, muncul dan hilang dengan fade opacity, lalu hilang sendiri setelah
/// `CustomMotion.snackbarVisible`.
/// Pesan baru mengganti teks dan memulai hitungan lagi. Posisi dan inset milik pemakai (mis. di bawah header).
/// TODO: Durasi tampil dan fade sementara sampai ada Figma.
@MainActor
public struct Snackbar: View {
    @Binding private var message: SnackbarMessage?

    /// `message` nil = tersembunyi; snackbar mengosongkannya sendiri setelah durasi tampil.
    public init(message: Binding<SnackbarMessage?>) {
        self._message = message
    }

    public var body: some View {
        ZStack {
            if let message {
                ActionBanner(text: message.text, tone: message.tone)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier(ComponentIdentifier.Snackbar.root)
                    .transition(.opacity)
                    .task(id: message.id) { await show(message) }
            }
        }
        .animation(.easeInOut(duration: CustomMotion.bannerFade), value: message)
    }
}

// MARK: - Helpers

private extension Snackbar {
    /// Dibacakan VoiceOver karena snackbar tidak mendapat fokus, lalu ditutup bila belum diganti pesan lain.
    func show(_ shown: SnackbarMessage) async {
        UIAccessibility.post(notification: .announcement, argument: shown.text)
        try? await Task.sleep(nanoseconds: UInt64(CustomMotion.snackbarVisible * Double(NSEC_PER_SEC)))
        guard !Task.isCancelled, message == shown else { return }
        message = nil
    }
}
