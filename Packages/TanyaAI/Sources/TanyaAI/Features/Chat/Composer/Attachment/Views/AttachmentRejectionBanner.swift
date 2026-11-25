//
//  AttachmentRejectionBanner.swift
//  TanyaAI
//
//  Created by Wendra on 26/11/26.
//

import DesignKit
import SwiftUI

/// Snackbar oranye di atas daftar pesan saat lampiran ditolak, seperti bar sesi agen tetapi tanpa tombol (keputusan
/// user). Hilang sendiri; penolakan berikutnya mengganti teksnya dan memulai hitungan lagi.
/// TODO: Durasi tampil dan posisi sementara sampai ada Figma.
@MainActor
struct AttachmentRejectionBanner: View {
    @Environment(\.locale) private var locale
    @Binding var rejection: ChatAttachmentRejection?
    /// Jarak dari atas wadah, mis. tinggi header bila bar sesi agen tidak tampil.
    let topInset: CGFloat

    var body: some View {
        if let rejection {
            ActionBanner(text: text(for: rejection), tone: .warning)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier(ChatElementIdentifier.attachmentRejection)
                .padding(.top, topInset)
                .task(id: rejection) { await show(rejection) }
        }
    }
}

// MARK: - Helpers

private extension AttachmentRejectionBanner {
    static let visibleNanoseconds: UInt64 = 3_000_000_000

    func text(for rejection: ChatAttachmentRejection) -> String {
        String(rejection.message, locale: locale)
    }

    /// Dibacakan VoiceOver karena snackbar tidak mendapat fokus, lalu ditutup bila belum diganti penolakan lain.
    func show(_ shown: ChatAttachmentRejection) async {
        UIAccessibility.post(notification: .announcement, argument: text(for: shown))
        try? await Task.sleep(nanoseconds: Self.visibleNanoseconds)
        guard !Task.isCancelled, rejection == shown else { return }
        rejection = nil
    }
}
