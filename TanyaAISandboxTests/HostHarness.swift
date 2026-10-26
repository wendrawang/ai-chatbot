//
//  HostHarness.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI
import UIKit

@testable import Tanya_AI_Sandbox

/// Main tiruan dengan destinasi detail yang dikendalikan test.
@MainActor
struct HostHarness {
    let appState = AppState()
    let probe = DestinationProbe()
    private let fixture: HostWindowFixture

    init() throws {
        // Test navigasi ini tentang chat; gerbang T&C diuji di TanyaAITermsTests dan UI test.
        TanyaAITermsStore().accept()
        fixture = try HostWindowFixture(HarnessMain(probe: probe).environmentObject(appState))
        settle()
    }

    var windowBounds: CGRect { fixture.controller.view.window?.bounds ?? .zero }
    var navigation: UINavigationController? { Self.find(UINavigationController.self, in: fixture.controller) }

    func settle() {
        fixture.settle()
        fixture.settle()
    }

    func close() {
        fixture.close()
    }

    private static func find<Controller: UIViewController>(_ type: Controller.Type, in controller: UIViewController)
        -> Controller?
    {
        if let match = controller as? Controller { return match }
        return controller.children.lazy.compactMap { find(type, in: $0) }.first
    }
}
