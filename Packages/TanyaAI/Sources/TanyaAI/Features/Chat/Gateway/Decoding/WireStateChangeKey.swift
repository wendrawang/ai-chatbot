//
//  WireStateChangeKey.swift
//  TanyaAI
//
//  Created by Wendra on 12/11/26.
//

/// Key `data` event `state`: `to` dibaca sebagai `WireStateChange.nextState`.
enum WireStateChangeKey: String, CodingKey {
    case nextState = "to"
}
