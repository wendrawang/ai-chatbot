//
//  SandboxTerms.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 26/10/26.
//

import Foundation

/// Hasil inquiry T&C Tanya AI. `version` disimpan saat disetujui.
struct SandboxTerms: Decodable, Equatable {
    let version: String
    let paragraphs: [String]
}
