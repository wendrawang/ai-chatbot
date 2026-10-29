//
//  TanyaAITransportError.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Foundation

/// Error yang dilempar `TanyaAIChatTransport` untuk respons HTTP selain 2xx.
public enum TanyaAITransportError: Error {
    /// `body` adalah error envelope gateway (`error_code`, `retryable`, `data`); boleh kosong.
    case response(statusCode: Int, body: Data)
}
