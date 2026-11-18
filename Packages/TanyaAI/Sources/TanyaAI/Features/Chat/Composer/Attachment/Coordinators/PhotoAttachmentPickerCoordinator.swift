//
//  PhotoAttachmentPickerCoordinator.swift
//  TanyaAI
//
//  Created by Wendra on 18/11/26.
//

import PhotosUI
import UniformTypeIdentifiers

/// Delegate galeri: memuat file gambar yang didukung, menyalinnya sebelum file sementara sistem dihapus, lalu
/// meneruskannya di main queue. Class karena delegate UIKit harus `NSObject`.
/// TODO: Pesan untuk format yang tidak didukung (mis. GIF) dan gagal memuat belum ada di desain; sementara diabaikan.
final class PhotoAttachmentPickerCoordinator: NSObject, PHPickerViewControllerDelegate {
    private let onPick: (URL) -> Void
    private let onDismiss: () -> Void

    init(onPick: @escaping (URL) -> Void, onDismiss: @escaping () -> Void) {
        self.onPick = onPick
        self.onDismiss = onDismiss
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        onDismiss()
        guard let provider = results.first?.itemProvider,
            let type = UTType.chatAttachmentImage(in: provider.registeredTypeIdentifiers)
        else { return }
        provider.loadFileRepresentation(forTypeIdentifier: type.identifier) { [onPick] url, _ in
            let copy = url.flatMap { try? FileManager.default.copyChatAttachment(from: $0) }
            DispatchQueue.main.async {
                guard let copy else { return }
                onPick(copy)
            }
        }
    }
}
