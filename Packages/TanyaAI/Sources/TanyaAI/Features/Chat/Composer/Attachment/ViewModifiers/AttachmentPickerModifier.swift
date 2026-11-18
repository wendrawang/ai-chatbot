//
//  AttachmentPickerModifier.swift
//  TanyaAI
//
//  Created by Wendra on 18/11/26.
//

import DesignKit
import SwiftUI

/// Pilihan sumber lampiran di bottom sheet DesignKit, lalu picker sistem untuk sumber yang dipilih. Dipasang di root
/// halaman supaya latar gelap sheet menutupi header dan composer. Picker sistem tetap dibuka lewat `.sheet` karena
/// itu layar milik iOS, bukan isi sheet DesignKit.
/// TODO: Tampilan isi sheet sementara memakai `OptionList` (judul, baris dengan keterangan format) sampai ada Figma.
/// Saat intent form memakai sheet di halaman yang sama, gabungkan ke satu pemasangan `.bottomSheet(item:)`.
@MainActor
struct AttachmentPickerModifier: ViewModifier {
    @Environment(\.locale) private var locale
    @Binding private var isPresented: Bool
    /// Picker sistem yang sedang terbuka; nil = tertutup.
    @State private var source: ChatAttachmentSource?
    private let onPick: (URL) -> Void

    init(isPresented: Binding<Bool>, onPick: @escaping (URL) -> Void) {
        _isPresented = isPresented
        self.onPick = onPick
    }

    func body(content: Content) -> some View {
        content
            .bottomSheet(isPresented: $isPresented, closeLabel: String(ChatCopy.attachmentClose, locale: locale)) {
                OptionList(
                    title: String(ChatCopy.liveAgentAttachment, locale: locale),
                    items: items,
                    onSelect: choose
                )
            }
            .sheet(item: $source) { picker($0) }
    }

    @ViewBuilder
    private func picker(_ source: ChatAttachmentSource) -> some View {
        switch source {
        case .gallery:
            PhotoAttachmentPicker(onPick: onPick, onDismiss: closePicker)
        case .file:
            DocumentAttachmentPicker(onPick: onPick, onDismiss: closePicker)
        }
    }
}

// MARK: - Helpers

private extension AttachmentPickerModifier {
    var items: [OptionItem] {
        ChatAttachmentSource.allCases.map { source in
            OptionItem(
                id: source.optionID,
                title: String(source.title, locale: locale),
                subtitle: String(source.formats, locale: locale)
            )
        }
    }

    /// Sheet ditutup lalu picker sistem dibuka untuk sumber yang diketuk.
    func choose(_ ids: [String]) {
        isPresented = false
        source = ChatAttachmentSource.allCases.first { $0.optionID == ids.first }
    }

    func closePicker() {
        source = nil
    }
}
