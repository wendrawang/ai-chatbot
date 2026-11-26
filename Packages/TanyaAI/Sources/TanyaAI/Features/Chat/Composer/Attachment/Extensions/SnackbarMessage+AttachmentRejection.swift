//
//  SnackbarMessage+AttachmentRejection.swift
//  TanyaAI
//
//  Created by Wendra on 26/11/26.
//

import DesignKit
import Foundation

extension SnackbarMessage {
    /// Penolakan lampiran tampil sebagai snackbar oranye (keputusan user).
    init(rejection: ChatAttachmentRejection, locale: Locale) {
        self.init(text: String(rejection.message, locale: locale), tone: .warning)
    }
}
