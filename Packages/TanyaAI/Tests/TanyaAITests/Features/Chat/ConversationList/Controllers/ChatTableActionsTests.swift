//
//  ChatTableActionsTests.swift
//  TanyaAITests
//
//  Created by Wendra on 6/11/26.
//

import SwiftUI
import Testing
import UIKit

@testable import TanyaAI

/// Sel yang tampil tidak dibangun ulang saat host mengganti handler, jadi aksinya harus tetap sampai ke yang baru.
@MainActor
@Suite(.serialized)
struct ChatTableActionsTests {
    private let link = "/link"

    @Test
    func aShownRowCallsTheLatestHandlers() async {
        let model = ActionModel()
        var shownActions: ChatRowActions?
        var calls: [String] = []
        var rowBuilds = 0
        let page = ActionPage(
            model: model,
            onCall: { calls.append($0) },
            onShow: {
                shownActions = $0
                rowBuilds += 1
            }
        )
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = UIHostingController(rootView: page)
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        await waitUntil { shownActions != nil }
        model.label = "After"
        await waitUntil {
            shownActions?.onOpenLink(link)
            return calls.last == "After"
        }
        shownActions?.onSelectFollowUp("Pertanyaan")
        #expect(calls.last == "After")
        #expect(rowBuilds == 1)
    }
}
