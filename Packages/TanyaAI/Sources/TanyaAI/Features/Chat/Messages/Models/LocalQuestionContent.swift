//
//  LocalQuestionContent.swift
//  TanyaAI
//
//  Created by Wendra on 27/11/26.
//

/// Isi kiriman nasabah yang tampil sebelum salinannya datang dari stream.
enum LocalQuestionContent: Equatable {
    /// Pertanyaan teks: bubble merah.
    case text(String)
    /// Lampiran selama dilayani agen: kartu file dengan salinan lokalnya.
    case attachment(ChatAttachmentFile)
}
