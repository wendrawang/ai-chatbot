//
//  SandboxCopyTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 27/10/26.
//

import Foundation
import Testing

@testable import Tanya_AI_Sandbox

/// Key copy dan fixture sandbox ditulis manual, jadi tes ini pengganti pengecekan compile R.swift.
struct SandboxCopyTests {
    @Test(arguments: ["en", "id", "zh-Hans"])
    func copyKeysMatchTheStringsTableExactly(language: String) throws {
        let path = try #require(
            Bundle.main.path(
                forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language
            )
        )
        let table = try #require(NSDictionary(contentsOfFile: path) as? [String: String])
        #expect(Set(table.keys) == Set(SandboxCopy.allCases.map(\.rawValue)))
        #expect(table.values.allSatisfy { !$0.isEmpty })
    }

    @Test
    func copyFollowsTheHostLocale() {
        #expect(String(SandboxCopy.back, locale: Locale(identifier: "id")) == "Kembali")
        #expect(String(SandboxCopy.back, locale: Locale(identifier: "en")) == "Back")
    }

    @Test(arguments: SandboxFixtureFile.allCases)
    func everyFixtureIsBundled(file: SandboxFixtureFile) throws {
        let url = try #require(file.url, "\(file)")
        #expect(try !Data(contentsOf: url).isEmpty)
    }
}
