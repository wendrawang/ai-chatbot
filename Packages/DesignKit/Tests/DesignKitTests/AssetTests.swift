//
//  AssetTests.swift
//  DesignKit
//
//  Created by Wendra on 17/10/26.
//

import Testing
import UIKit

@testable import DesignKit

struct AssetTests {
    @Test(arguments: DesignIcon.allCases)
    func everyIconLoadsFromThePackageBundle(icon: DesignIcon) throws {
        let loaded = try #require(UIImage(icon), "\(icon)")
        #expect(loaded.size == CGSize(width: 24, height: 24))
        #expect(loaded.renderingMode == .alwaysTemplate)
    }

    @Test
    func everyImagesetHasAnIconCase() throws {
        let names = try FileManager.default.contentsOfDirectory(atPath: Self.catalogSourcePath)
            .filter { $0.hasSuffix(".imageset") }
            .map { String($0.dropLast(".imageset".count)) }
        #expect(Set(names) == Set(DesignIcon.allCases.map(\.rawValue)))
    }
}

// MARK: - Helpers

private extension AssetTests {
    /// Asset catalog sumber; dibaca dari repo karena `.car` hasil compile tidak bisa didaftar namanya.
    static var catalogSourcePath: String {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources/DesignKit/Resources/Assets.xcassets").path
    }
}
