//
//  ChatScreenContentTests.swift
//  TanyaAITests
//
//  Created by Wendra on 6/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import TanyaAI

/// Konten sisipan host berada di dalam sel table, jadi perubahan state host harus sampai ke sel yang sedang tampil.
@MainActor
@Suite(.serialized)
struct ChatScreenContentTests {
    @Test
    func injectedContentFollowsTheStateOfTheHost() async {
        let model = ContentModel()
        var label: String?
        let window = makeWindow(model: model, onRender: { label = $0 })
        defer { window.isHidden = true }
        await waitUntil { label == "Before" }
        model.label = "After"
        await waitUntil { label == "After" }
    }

    /// Tinggi baris ikut berubah, jadi konten yang tumbuh tidak terpotong oleh tinggi lama.
    @Test
    func injectedContentResizesItsRow() async {
        let model = ContentModel()
        var frameHeight: CGFloat?
        let window = makeWindow(model: model, onResize: { frameHeight = $0 })
        defer { window.isHidden = true }
        await waitUntil { frameHeight == ContentModel.shortHeight }
        model.height = ContentModel.tallHeight
        await waitUntil { frameHeight == ContentModel.tallHeight }
    }

    /// Host menyembunyikan konten lewat `if`: tipe kontennya tetap bukan `EmptyView`, jadi barisnya tetap ada.
    @Test
    func hiddenContentLeavesNoEmptySpace() async throws {
        let model = ContentModel()
        var frameHeight: CGFloat?
        let window = makeWindow(model: model, onResize: { frameHeight = $0 })
        defer { window.isHidden = true }
        await waitUntil { frameHeight == ContentModel.shortHeight }
        let table = try #require(window.nestedTable as UITableView?)
        model.isVisible = false
        await waitUntil { table.lastRowHeight != ContentModel.shortHeight }
        #expect(table.lastRowHeight <= 1)
        model.isVisible = true
        await waitUntil { abs(table.lastRowHeight - ContentModel.shortHeight) <= 1 }
    }

    /// Menyegarkan konten terjadi di dalam update halaman, jadi tidak boleh memicu update berikutnya tanpa henti.
    @Test
    func anIdlePageStopsRebuildingTheContent() async throws {
        let model = ContentModel()
        var renders = 0
        let window = makeWindow(model: model, onRender: { _ in renders += 1 })
        defer { window.isHidden = true }
        await waitUntil { renders > 0 }
        try await Task.sleep(nanoseconds: 300_000_000)
        let settledRenders = renders
        try await Task.sleep(nanoseconds: 300_000_000)
        #expect(renders == settledRenders)
    }

    private func makeWindow(
        model: ContentModel,
        onRender: @escaping (String) -> Void = { _ in },
        onResize: @escaping (CGFloat) -> Void = { _ in }
    ) -> UIWindow {
        let host = TanyaAIHost(bridge: TanyaAIBridge(transport: FakeChatTransport()))
        let page = ContentPage(host: host, model: model, onRender: onRender, onResize: onResize)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = UIHostingController(rootView: page)
        window.makeKeyAndVisible()
        window.rootViewController?.view.layoutIfNeeded()
        return window
    }
}

private extension UIView {
    var nestedTable: UITableView? {
        (self as? UITableView) ?? subviews.lazy.compactMap(\.nestedTable).first
    }
}

private extension UITableView {
    var lastRowHeight: CGFloat {
        layoutIfNeeded()
        let row = numberOfRows(inSection: .zero) - 1
        return rectForRow(at: IndexPath(row: row, section: .zero)).height
    }
}
