import DesignKit
import Foundation
import SwiftUI
import TanyaAIDomain
import TanyaAITestSupport
import UIKit
import XCTest

@testable import TanyaAI
@testable import TanyaAIPresentation

@MainActor
final class TanyaAILifecycleTests: XCTestCase {
    func testRenderedChatsReleaseAcrossRepeatedCycles() {
        for _ in 0..<25 {
            weak var releasedModel: TanyaAIChatViewModel?
            weak var releasedController: UIViewController?
            autoreleasepool {
                let repository = TanyaAIRepositoryFixture()
                let viewModel = TanyaAIChatViewModel(repository: repository)
                repository.appendMixedMessages()
                let controller = UIHostingController(rootView: ChatScreen(viewModel: viewModel))
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = controller
                window.makeKeyAndVisible()
                controller.view.layoutIfNeeded()
                releasedModel = viewModel
                releasedController = controller
                window.isHidden = true
                window.rootViewController = nil
            }
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
            XCTAssertNil(releasedController)
            XCTAssertNil(releasedModel)
        }
    }

    func testChatViewModelReleasesAndDisconnectsSession() {
        let repository = TanyaAIRepositoryFixture()
        weak var weakViewModel: TanyaAIChatViewModel?

        autoreleasepool {
            var viewModel: TanyaAIChatViewModel? = TanyaAIChatViewModel(
                repository: repository
            )
            viewModel?.sendMessage("performance fixture")
            weakViewModel = viewModel
            viewModel = nil
        }

        XCTAssertNil(weakViewModel)
        XCTAssertTrue(repository.isDisconnected)
    }

    func testCompleteFeatureGraphReleasesAfterDismissal() {
        weak var weakController: UIViewController?

        autoreleasepool {
            var controller: UIViewController? = TanyaAIModule.makeViewController(
                dependencies: makeDependencies()
            )
            controller?.loadViewIfNeeded()
            weakController = controller
            controller = nil
        }

        XCTAssertNil(weakController)
    }

    private func makeDependencies() -> TanyaAIDependencies {
        TanyaAIDependencies(
            chatSession: MockTanyaAIChatSession.figma(),
            theme: .sandbox
        )
    }
}
