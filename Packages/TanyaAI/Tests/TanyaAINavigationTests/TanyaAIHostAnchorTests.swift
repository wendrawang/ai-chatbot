import SwiftUI
import TanyaAITestSupport
import UIKit
import XCTest
@testable import TanyaAI

@MainActor
final class TanyaAIHostAnchorTests: XCTestCase {
    func testOptionalHostKeepsMainContent() throws {
        let state = AnchorHostState()
        let probe = AnchorContentProbe()
        let controller = UIHostingController(rootView: AnchorMainFixture(state: state, probe: probe))
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
        }
        settle(controller)
        let field = try XCTUnwrap(probe.field)
        field.text = "Customer's existing input"
        let originalChildren = controller.children.count

        state.host = makeHost()
        settle(controller)
        XCTAssertTrue(probe.field === field)
        XCTAssertEqual(probe.creationCount, 1)
        XCTAssertEqual(field.text, "Customer's existing input")
        XCTAssertGreaterThan(controller.children.count, originalChildren)

        state.host = nil
        settle(controller)
        XCTAssertTrue(probe.field === field)
        XCTAssertEqual(probe.creationCount, 1)
        XCTAssertEqual(field.text, "Customer's existing input")
        XCTAssertEqual(controller.children.count, originalChildren)
    }

    func testAnchorReleasesWithHost() {
        weak var releasedHost: TanyaAIHost?
        weak var releasedController: UIViewController?
        autoreleasepool {
            let host = makeHost()
            let controller = UIHostingController(rootView: Text("Main").tanyaAIHost(host))
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = controller
            window.makeKeyAndVisible()
            settle(controller)
            releasedHost = host
            releasedController = controller
            window.isHidden = true
            window.rootViewController = nil
        }
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertNil(releasedController)
        XCTAssertNil(releasedHost)
    }

    private func makeHost() -> TanyaAIHost {
        TanyaAIHost(
            theme: .sandbox, deeplinkScheme: "ocbcid", deeplinkHost: "mobile",
            makeSession: { MockTanyaAIChatSession.sandbox() }, onDeeplink: { _ in }
        )
    }

    private func settle(_ controller: UIViewController) {
        controller.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        controller.view.layoutIfNeeded()
    }

}

private final class AnchorHostState: ObservableObject {
    @Published var host: TanyaAIHost?
}

private final class AnchorContentProbe {
    weak var field: UITextField?
    var creationCount = 0
}

private struct AnchorMainFixture: View {
    @ObservedObject var state: AnchorHostState
    let probe: AnchorContentProbe

    var body: some View {
        NavigationView {
            AnchorMainField(probe: probe)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tanyaAIHost(state.host)
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
