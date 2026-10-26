//
//  TanyaAIServerEvent.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Satu event SSE: nama dari baris `event:` dan isi dari baris `data:`.
public struct TanyaAIServerEvent: Equatable, Sendable {
    public let name: String
    public let data: Data

    public init(name: String, data: Data) {
        self.name = name
        self.data = data
    }
}
