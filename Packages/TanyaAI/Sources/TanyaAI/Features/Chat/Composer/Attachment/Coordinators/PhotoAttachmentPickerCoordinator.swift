//
//  PhotoAttachmentPickerCoordinator.swift
//  TanyaAI
//
//  Created by Wendra on 18/11/26.
//

import PhotosUI
import UniformTypeIdentifiers

/// Delegate galeri: memuat file gambar yang didukung, menyalinnya sebelum file sementara sistem dihapus, lalu
/// meneruskannya di main queue. Galeri sistem tidak bisa memfilter per format, jadi foto berformat lain (mis. GIF,
/// WebP) dan foto di atas batas ukuran dilaporkan lewat `onReject`. Class karena delegate UIKit harus `NSObject`.
final class PhotoAttachmentPickerCoordinator: NSObject, PHPickerViewControllerDelegate {
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

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        onDismiss()
        guard let provider = results.first?.itemProvider else { return }
        guard let type = UTType.chatAttachmentImage(in: provider.registeredTypeIdentifiers) else {
            return onReject(.unsupportedFormat)
        }
        // File sementara sistem hanya berlaku selama callback ini, jadi disalin di sini sebelum pindah ke main queue.
        provider.loadFileRepresentation(forTypeIdentifier: type.identifier) { [onPick, onReject] url, _ in
            guard let url else { return }
            FileManager.default.deliverChatAttachmentCopy(of: url, onPick: onPick, onReject: onReject)
        }
    }
}
