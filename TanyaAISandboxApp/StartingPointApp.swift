import DesignKit
import SwiftUI
import TanyaAI

@main
@MainActor
struct StartingPointApp: App {
    private let options = SandboxOptions(arguments: ProcessInfo.processInfo.arguments)

    init() {
        do { try FontFace.registerFonts() } catch {
            assertionFailure(SandboxOptions.fontFailure + String(describing: error))
        }
    }

    var body: some Scene {
        WindowGroup {
            ChatScreen { _ in !options.isRejectingSend }
                .environment(\.locale, options.locale ?? .current)
                .preferredColorScheme(.light)
        }
    }
}
