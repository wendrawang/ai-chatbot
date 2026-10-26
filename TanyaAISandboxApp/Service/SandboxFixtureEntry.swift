//
//  SandboxFixtureEntry.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 27/10/26.
//

/// Satu pesan pola history di fixture.
struct SandboxFixtureEntry: Decodable {
    let role: SandboxRole
    let text: String
}
