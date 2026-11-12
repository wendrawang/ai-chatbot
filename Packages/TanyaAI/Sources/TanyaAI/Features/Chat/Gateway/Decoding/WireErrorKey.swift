//
//  WireErrorKey.swift
//  TanyaAI
//
//  Created by Wendra on 12/11/26.
//

/// Key error envelope gateway yang dibaca `WireError`: `retryable` dan `data`.
enum WireErrorKey: String, CodingKey {
    case isRetryable = "retryable"
    case data
}
