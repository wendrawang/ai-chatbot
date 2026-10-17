//
//  AssetTests.swift
//  DesignKit
//
//  Created by Wendra on 17/10/26.
//

import UIKit
import XCTest

@testable import DesignKit

final class AssetTests: XCTestCase {
    func testGeneratedImageResourcesLoadFromThePackageBundle() throws {
        for resource in [R.image.sendArrow, R.image.backArrow, R.image.moreMenu] {
            let image = try XCTUnwrap(UIImage(resource: resource), resource.name)
            XCTAssertEqual(image.size, CGSize(width: 24, height: 24), resource.name)
            XCTAssertEqual(image.renderingMode, .alwaysTemplate, resource.name)
        }
    }
}
