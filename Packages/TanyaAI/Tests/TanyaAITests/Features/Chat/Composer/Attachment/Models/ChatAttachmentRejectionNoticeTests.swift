//
//  ChatAttachmentRejectionNoticeTests.swift
//  TanyaAI
//
//  Created by Wendra on 26/11/26.
//

import Testing

@testable import TanyaAI

/// Penolakan dengan alasan sama berturut-turut adalah kejadian baru, supaya snackbar tampil tiga detik penuh lagi.
struct ChatAttachmentRejectionNoticeTests {
    @Test
    func repeatedRejectionsWithTheSameReasonAreNewNotices() {
        let first = ChatAttachmentRejectionNotice(reason: .tooLarge)
        let second = ChatAttachmentRejectionNotice(reason: .tooLarge)
        #expect(first != second)
        #expect(first.id != second.id)
        #expect(first.reason == second.reason)
    }
}
