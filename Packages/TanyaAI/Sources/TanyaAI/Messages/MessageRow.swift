//
//  MessageRow.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import DesignKit
import SwiftUI

/// Satu baris daftar: chat user, jawaban bot, atau penanda sedang menjawab.
/// Tampilan sementara teks biasa; bubble final dan Markdown menyusul.
@MainActor
struct MessageRow: View {
    enum Kind: Equatable {
        case message(ChatMessage)
        case replying
    }

    @Environment(\.locale)
    private var locale
    @Environment(\.designColors)
    private var colors
    let kind: Kind
    let handlers: MessageHandlers

    var body: some View {
        Group {
            switch kind {
            case .message(let message) where message.role == .user:
                question(message)
            case .message(let message):
                answer(message)
            case .replying:
                Text(String(resource: R.string.localizable.chatReplying, locale: locale))
                    .foregroundColor(colors.colorsTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier(ChatElementIdentifier.replying)
            }
        }
        .font(Font(FontFace.openSansRegular.font(size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork)))
        .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
        .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
    }

    private func question(_ message: ChatMessage) -> some View {
        VStack(alignment: .trailing, spacing: FigmaSize.spacingSmall.scaledToArtwork) {
            Text(message.text)
                .foregroundColor(colors.colorsTextPrimaryLight)
                .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
                .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
                .background(
                    RoundedRectangle(cornerRadius: CustomSizes.Card.cornerRadius.scaledToArtwork)
                        .fill(colors.colorsButtonActive)
                )
                .accessibilityIdentifier(ChatElementIdentifier.question)
            if message.delivery == .failed {
                failure(message)
            }
        }
        .padding(.leading, FigmaSize.spacingExtraLarge.scaledToArtwork)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func failure(_ message: ChatMessage) -> some View {
        Button {
            handlers.resend(message.id)
        } label: {
            Text(String(resource: R.string.localizable.chatSendFailed, locale: locale))
                .foregroundColor(colors.colorsTextNegative)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(ChatElementIdentifier.resend)
    }

    private func answer(_ message: ChatMessage) -> some View {
        Text(message.text)
            .foregroundColor(colors.colorsTextPrimaryDark)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier(ChatElementIdentifier.answer)
    }
}

/// Aksi dari baris ke view model; closure agar baris tetap value type yang ringan.
struct MessageHandlers {
    let resend: (String) -> Void
    let loadOlder: () -> Void
}

/// Isi cell daftar. Cell UIKit tidak mewarisi environment SwiftUI, jadi locale dan palette
/// dipasang ulang di sini.
struct MessageRowContent: View {
    let row: MessageRow.Kind
    let handlers: MessageHandlers
    let locale: Locale
    let colors: any FigmaColorProtocol

    var body: some View {
        MessageRow(kind: row, handlers: handlers)
            .environment(\.locale, locale)
            .designColors(colors)
    }
}
