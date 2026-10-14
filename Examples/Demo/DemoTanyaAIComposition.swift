#if DEBUG
    import Foundation
    import TanyaAI
    import TanyaAITestSupport

    @MainActor
    final class DemoTanyaAIComposition {
        func makeHost(theme: TanyaAITheme = .sandbox, onDeeplink: @escaping (URL) -> Void) -> TanyaAIHost {
            TanyaAIHost(
                theme: theme,
                deeplinkScheme: "ocbcid", deeplinkHost: "mobile",
                makeSession: { MockTanyaAIChatSession.figma() },
                makeNewSession: { MockTanyaAIChatSession.figma() },
                onDeeplink: onDeeplink
            )
        }
    }
#endif
