//
//  WireCancelKey.swift
//  TanyaAI
//
//  Created by Wendra on 12/11/26.
//

/// Key `data` respons cancel: `canceled` dibaca sebagai `WireCancel.isCanceled`.
enum WireCancelKey: String, CodingKey {
    case isCanceled = "canceled"
}
