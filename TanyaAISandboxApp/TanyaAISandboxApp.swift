import Foundation
import SwiftUI
import TanyaAI

@main
struct TanyaAISandboxApp: App {
    @StateObject private var presentationGateway: TanyaAIPresentationGateway
    private let showsStandaloneFeature: Bool

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        let showsShowcase = arguments.contains("--showcase")
        let showsStressChat = arguments.contains("--stress-chat")
        showsStandaloneFeature = showsShowcase || showsStressChat

        let dependencies = SandboxTanyaAIFactory.makeDependencies(
            showsShowcase: showsStandaloneFeature
        )
        let initialPrompt: String?
        if showsStressChat {
            initialPrompt = "stress conversation"
        } else if showsShowcase {
            initialPrompt = "showcase all bubbles"
        } else {
            initialPrompt = nil
        }
        let configuration = TanyaAIConfiguration(
            initialPrompt: initialPrompt
        )
        _presentationGateway = StateObject(
            wrappedValue: TanyaAIPresentationGateway(
                dependencies: dependencies,
                configuration: configuration
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            if showsStandaloneFeature {
                presentationGateway.makeView()
            } else {
                LegacyRootScreen(
                    tanyaAIPresenter: presentationGateway
                )
            }
        }
    }
}
