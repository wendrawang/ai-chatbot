//
//  SnackbarMessageAttachmentRejectionTests.swift
//  TanyaAI
//
//  Created by Wendra on 26/11/26.
//

import DesignKit
import Foundation
import Testing

@testable import TanyaAI

/// Setiap alasan penolakan lampiran menjadi snackbar oranye dengan teks sesuai bahasa halaman.
struct SnackbarMessageAttachmentRejectionTests {
    @Test(arguments: [ChatAttachmentRejection.unsupportedFormat, .tooLarge])
    func rejectionsBecomeLocalizedWarnings(rejection: ChatAttachmentRejection) {
        let locale = Locale(identifier: "id")
        let message = SnackbarMessage(rejection: rejection, locale: locale)
        #expect(message.tone == .warning)
        #expect(message.text == String(rejection.message, locale: locale))
        #expect(!message.text.isEmpty)
    }
}
