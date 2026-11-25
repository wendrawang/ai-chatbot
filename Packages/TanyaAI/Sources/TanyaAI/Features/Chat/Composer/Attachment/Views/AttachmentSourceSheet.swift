//
//  AttachmentSourceSheet.swift
//  TanyaAI
//
//  Created by Wendra on 20/11/26.
//

import DesignKit
import SwiftUI

/// Isi bottom sheet sumber lampiran: Galeri dan File dengan keterangan format. Lampiran yang ditolak tampil sebagai
/// snackbar di halaman chat (`AttachmentRejectionBanner`), bukan di sheet ini.
/// TODO: Tampilan sementara memakai `OptionList` (judul, baris dengan keterangan format) sampai ada Figma.
@MainActor
struct AttachmentSourceSheet: View {
    @Environment(\.locale) private var locale
    let onSelect: (ChatAttachmentSource) -> Void

    var body: some View {
        OptionList(title: String(ChatCopy.liveAgentAttachment, locale: locale), items: items, onSelect: select)
    }
}

// MARK: - Helpers

private extension AttachmentSourceSheet {
    var items: [OptionItem] {
        ChatAttachmentSource.allCases.map { source in
            OptionItem(
                id: source.optionID,
                title: String(source.title, locale: locale),
                subtitle: String(source.formats, locale: locale)
            )
        }
    }

    func select(_ ids: [String]) {
        guard let source = ChatAttachmentSource.allCases.first(where: { $0.optionID == ids.first }) else { return }
        onSelect(source)
    }
}
