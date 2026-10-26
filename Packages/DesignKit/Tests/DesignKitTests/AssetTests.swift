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
    @Test
    func generatedImageResourcesLoadFromThePackageBundle() throws {
        for resource in [R.image.sendArrow, R.image.backArrow, R.image.moreMenu] {
            let image = try #require(UIImage(resource: resource), "\(resource.name)")
            #expect(image.size == CGSize(width: 24, height: 24), "\(resource.name)")
            #expect(image.renderingMode == .alwaysTemplate, "\(resource.name)")
        }
    }
}
