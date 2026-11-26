//
//  DocumentAttachmentPickerCoordinator.swift
//  TanyaAI
//
//  Created by Wendra on 18/11/26.
//

import UIKit

/// Delegate aplikasi Files: menutup sheet pembungkusnya, lalu menyalin file pertama di background dan meneruskannya
/// di main queue. File di atas batas ukuran ditolak sebelum disalin dan dilaporkan lewat `onReject`. Class karena
/// delegate UIKit harus `NSObject`.
/// TODO: Gagal koordinasi atau salin (mis. iCloud Drive offline) belum punya umpan balik; menunggu desain.
final class DocumentAttachmentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    private let onPick: (URL) -> Void
    private let onReject: (ChatAttachmentRejection) -> Void
    private let onDismiss: () -> Void

    init(
        onPick: @escaping (URL) -> Void,
        onReject: @escaping (ChatAttachmentRejection) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.onPick = onPick
        self.onReject = onReject
        self.onDismiss = onDismiss
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        onDismiss()
        guard let url = urls.first else { return }
        // Picker dibuka tanpa `asCopy`, jadi file asli dibaca lewat akses security-scoped selama disalin. Pembacaan
        // dikoordinasikan karena file milik provider lain (mis. iCloud Drive) bisa belum tersedia lokal atau sedang
        // dipindahkan; ukuran dicek dan file disalin dari URL yang diberikan koordinator.
        DispatchQueue.global(qos: .userInitiated).async { [onPick, onReject] in
            let isAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if isAccessing { url.stopAccessingSecurityScopedResource() }
            }
            var coordinationError: NSError?
            NSFileCoordinator().coordinate(readingItemAt: url, error: &coordinationError) { readableURL in
                FileManager.default.deliverChatAttachmentCopy(of: readableURL, onPick: onPick, onReject: onReject)
            }
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        onDismiss()
    }
}
