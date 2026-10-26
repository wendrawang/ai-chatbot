//
//  SandboxFixtureReply.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 27/10/26.
//

/// Jawaban fixture untuk pertanyaan yang mengandung salah satu kata kunci.
struct SandboxFixtureReply: Decodable {
    let keywords: [String]
    let text: String
}
