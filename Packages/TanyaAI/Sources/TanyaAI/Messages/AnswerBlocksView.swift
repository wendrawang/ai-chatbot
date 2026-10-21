//
//  AnswerBlocksView.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import DesignKit
import SwiftUI

/// Menerjemahkan blok jawaban ke komponen DesignKit, berurutan sesuai data.
@MainActor
struct AnswerBlocksView: View {
    let message: ChatMessage
    let handlers: MessageHandlers

    var body: some View {
        ForEach(message.blocks.indices, id: \.self) { index in
            block(message.blocks[index], index: index)
        }
    }

    @ViewBuilder
    private func block(_ block: ChatBlock, index: Int) -> some View {
        switch block {
        case .text(let text):
            RichText(text, onOpenLink: handlers.openLink)
        case .table(let table):
            DataTable(
                columns: table.columns.map { DataTable.Column(title: $0.title, isTrailing: $0.isTrailing ?? false) },
                rows: table.rows, footer: table.footer.map { DataTable.Footer(label: $0.label, value: $0.value) }
            )
        case .options(let options):
            OptionList(
                items: options.items.map { OptionList.Item(id: $0.id, label: $0.label) },
                selectedID: message.selections[index], isEnabled: message.isInteractive
            ) { selected in
                guard let item = options.items.first(where: { $0.id == selected.id }) else { return }
                handlers.select(item, index, message.id)
            }
        case .media(let media):
            MediaCard(
                imageURL: media.imageUrl, caption: media.caption,
                onTap: media.action.map { target in
                    { handlers.perform(target, media.caption) }
                })
        case .actions(let items):
            VStack(alignment: .leading, spacing: FigmaSize.spacingMedium.scaledToArtwork) {
                ForEach(items.indices, id: \.self) { item in actionButton(items[item]) }
            }
        case .suggestions(let items):
            SuggestionList(titles: items.map(\.label), isEnabled: message.isInteractive) { item in
                handlers.perform(items[item].action, items[item].label)
            }
        case .unsupported:
            EmptyView()
        }
    }

    /// Link tetap aktif di riwayat; prompt/intent hanya aktif pada jawaban terakhir.
    private func actionButton(_ item: ActionItem) -> some View {
        ActionButton(
            item.label, style: style(item.style),
            isEnabled: item.action.type == .link || message.isInteractive
        ) { handlers.perform(item.action, item.label) }
    }

    private func style(_ style: ActionItem.Style?) -> ActionButton.Style {
        switch style {
        case .suggestion: return .suggestion
        case .link: return .link
        case .filled: return .filled
        case .chip, nil: return .chip
        }
    }
}
