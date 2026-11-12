//
//  HostingTableViewCellTests.swift
//  DesignKitTests
//
//  Created by Wendra on 5/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import DesignKit

/// Jalur iOS 15 tidak punya runtime di mesin ini, jadi hosting controller-nya diuji langsung lewat `configureLegacy`.
@MainActor
struct HostingTableViewCellTests {
    private typealias Cell = HostingTableViewCell<Text>

    @Test
    func legacyContentJoinsTheParentAndLeavesWhenDetached() {
        let parent = UIViewController()
        let cell = Cell(style: .default, reuseIdentifier: Cell.reuseIdentifier)
        cell.configureLegacy(rootView: Text(verbatim: "Halo"), parent: parent)
        #expect(parent.children.count == 1)
        #expect(cell.contentView.subviews.count == 1)
        cell.detachHostedController()
        #expect(parent.children.isEmpty)
        #expect(cell.contentView.subviews.isEmpty)
    }

    /// Di iOS 15 hosting controller child memunculkan lagi navigation bar yang disembunyikan host.
    @Test
    func legacyContentCannotReachTheNavigationBarOfTheHost() throws {
        let parent = UIViewController()
        let navigation = UINavigationController(rootViewController: parent)
        let cell = Cell(style: .default, reuseIdentifier: Cell.reuseIdentifier)
        cell.configureLegacy(rootView: Text(verbatim: "Halo"), parent: parent)
        let controller = try #require(parent.children.first)
        #expect(parent.navigationController === navigation)
        #expect(controller.navigationController == nil)
    }

    @Test
    func legacyContentReusesItsControllerOnReconfigure() {
        let parent = UIViewController()
        let cell = Cell(style: .default, reuseIdentifier: Cell.reuseIdentifier)
        cell.configureLegacy(rootView: Text(verbatim: "Satu"), parent: parent)
        let controller = parent.children.first
        cell.configureLegacy(rootView: Text(verbatim: "Dua"), parent: parent)
        #expect(parent.children.count == 1)
        #expect(parent.children.first === controller)
    }

    @Test
    func reuseEmptiesTheLegacyContent() {
        let parent = UIViewController()
        let cell = Cell(style: .default, reuseIdentifier: Cell.reuseIdentifier)
        cell.configureLegacy(rootView: Text(verbatim: "Halo"), parent: parent)
        cell.prepareForReuse()
        #expect(parent.children.isEmpty)
    }

    /// Tinggi baris mengikuti konten saja: spacing desain tidak boleh bertambah oleh minimum bawaan sistem.
    @Test(arguments: [18, 24, 80] as [CGFloat], [false, true])
    func aRowIsAsTallAsItsContent(height: CGFloat, isLegacy: Bool) {
        let fixture = HostedRowFixture(contentHeight: height, isLegacy: isLegacy)
        defer { fixture.close() }
        #expect(abs(fixture.rowHeight - height) < 0.5)
    }

    /// Table menganggap tinggi 0 sebagai belum terukur dan memakai tinggi bawaan, jadi baris kosong menjadi jarak.
    @Test(arguments: [false, true])
    func anEmptyRowLeavesNoVisibleSpace(isLegacy: Bool) {
        let fixture = HostedRowFixture(contentHeight: .zero, isLegacy: isLegacy)
        defer { fixture.close() }
        #expect(fixture.rowHeight <= CustomSizes.HostedTable.minimumRowHeight.scaledToArtwork)
    }

    @Test
    func theReuseIdentifierDiffersPerContent() {
        #expect(HostingTableViewCell<Text>.reuseIdentifier != HostingTableViewCell<Image>.reuseIdentifier)
    }
}
