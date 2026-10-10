import SwiftUI
import XCTest

@testable import DesignKit

@MainActor
final class HostingCellLifecycleTests: XCTestCase {
    func testReuseDetachesAndReattachesTheSameHostingController() {
        let parent = UIViewController()
        let cell = HostingTableViewCell<Text>(style: .default, reuseIdentifier: "fixture")
        cell.configureLegacy(rootView: Text("First"), parent: parent)
        XCTAssertEqual(parent.children.count, 1)
        let hosted = parent.children[0]
        cell.prepareForReuse()
        XCTAssertTrue(parent.children.isEmpty)
        XCTAssertNil(hosted.view.superview)
        cell.configureLegacy(rootView: Text("Second"), parent: parent)
        XCTAssertTrue(parent.children[0] === hosted)
        XCTAssertTrue(hosted.view.superview === cell.contentView)
        cell.detachHostedController()
        XCTAssertTrue(parent.children.isEmpty)
    }

    func testDetachmentAllowsHostedControllerToRelease() {
        let parent = UIViewController()
        weak var released: UIViewController?
        autoreleasepool {
            let cell = HostingTableViewCell<Text>(style: .default, reuseIdentifier: "fixture")
            cell.configureLegacy(rootView: Text("Content"), parent: parent)
            released = parent.children.first
            cell.detachHostedController()
        }
        XCTAssertNil(released)
        XCTAssertTrue(parent.children.isEmpty)
    }
}
