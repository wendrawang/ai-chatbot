//
//  SandboxFixtureFile.swift
//  TanyaAISandbox
//
//  Created by Wendra on 27/10/26.
//

import Foundation

/// File JSON dummy BE di `Resources/Fixtures`.
enum SandboxFixtureFile: String, CaseIterable {
    case chatDummy = "ChatDummy"
    case termsDummy = "TermsDummy"

    /// Lokasi file di bundle app; nil bila file tidak ikut ter-bundle.
    var url: URL? {
        Bundle.main.url(forResource: rawValue, withExtension: "json")
    }
}
