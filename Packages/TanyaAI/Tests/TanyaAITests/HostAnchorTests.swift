//
//  HostAnchorTests.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI
import UIKit
import XCTest

@testable import TanyaAI

@MainActor
final class HostAnchorTests: XCTestCase {
    func testOptionalHostKeepsExistingContentAndDetachesOldHost() throws {
        let state = AnchorHostState()
        let probe = AnchorContentProbe()
        let fixture = HostWindowFixture(AnchorMainFixture(state: state, probe: probe))
        defer { fixture.close() }
        let field = try XCTUnwrap(probe.field)
        field.text = "Host's existing draft"
        let host = TanyaAIHost { _ in true }
        state.host = host
        fixture.settle()
        XCTAssertTrue(probe.field === field)
        XCTAssertEqual(probe.creationCount, 1)
        XCTAssertEqual(field.text, "Host's existing draft")
        state.host = nil
        fixture.settle()
        XCTAssertTrue(probe.field === field)
        XCTAssertEqual(probe.creationCount, 1)
        XCTAssertEqual(field.text, "Host's existing draft")
        host.present()
        XCTAssertFalse(host.isPresenting)
        XCTAssertNil(fixture.controller.presentedViewController)
    }

    func testReplacingHostDetachesPreviousInstance() {
        let state = AnchorHostState()
        let previous = TanyaAIHost { _ in true }
        state.host = previous
        let fixture = HostWindowFixture(AnchorMainFixture(state: state, probe: AnchorContentProbe()))
        defer { fixture.close() }
        state.host = TanyaAIHost { _ in true }
        fixture.settle()
        previous.present()
        XCTAssertFalse(previous.isPresenting)
        XCTAssertNil(fixture.controller.presentedViewController)
    }
}

private final class AnchorHostState: ObservableObject {
    @Published
    var host: TanyaAIHost?
}

private final class AnchorContentProbe {
    weak var field: UITextField?
    var creationCount = 0
}

private struct AnchorMainFixture: View {
    @ObservedObject
    var state: AnchorHostState
    let probe: AnchorContentProbe

    var body: some View {
        AnchorMainField(probe: probe).tanyaAIHost(state.host)
    }
}

private struct AnchorMainField: UIViewRepresentable {
    let probe: AnchorContentProbe

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        probe.creationCount += 1
        probe.field = field
        return field
    }

    func updateUIView(_ field: UITextField, context: Context) {}
}
