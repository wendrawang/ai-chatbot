//
//  DocumentAttachmentPicker.swift
//  TanyaAI
//
//  Created by Wendra on 18/11/26.
//

import SwiftUI
import UniformTypeIdentifiers

/// Aplikasi Files untuk satu PDF atau gambar lampiran. Tanpa `asCopy`, supaya ukuran file dicek sebelum disalin dan
/// file besar (mis. 1 GB) tidak sempat disalin sistem ke folder aplikasi.
@MainActor
struct DocumentAttachmentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    /// File di atas batas ukuran.
    let onReject: (ChatAttachmentRejection) -> Void
    let onDismiss: () -> Void

    func makeCoordinator() -> DocumentAttachmentPickerCoordinator {
        DocumentAttachmentPickerCoordinator(onPick: onPick, onReject: onReject, onDismiss: onDismiss)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: UTType.chatAttachments, asCopy: false)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIDocumentPickerViewController, context: Context) {}
}
