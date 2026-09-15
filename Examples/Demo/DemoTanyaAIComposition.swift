#if DEBUG
import Foundation
import TanyaAI
import TanyaAITestSupport

/// Tanya AI with no backend behind it.
///
/// The bot answers from fixtures, so every bubble can be seen, tapped and
/// reviewed before a vendor SDK exists. Swapping in a real one later is one
/// line - `makeSession` - and nothing else in the host moves.
///
/// Wrapped in `#if DEBUG` on purpose. `TanyaAITestSupport` carries fabricated
/// answers including confirmation cards, and a Release build that can draw an
/// invented transfer approval is a defect, not a demo.
final class DemoTanyaAIComposition {
    /// Accepts one PIN so the confirmation flow can be walked end to end.
    /// Any other PIN is refused, which is the more interesting half to look at.
    private let authorization = MockTanyaAIAuthorizationService(
        acceptedPIN: "123456"
    )

    private let deeplinkScheme: String
    private let deeplinkHost: String?

    /// - Parameters:
    ///   - deeplinkScheme: your app's own scheme. Hand-off links from the
    ///     fixtures use it, so the demo exercises the real filter rather than
    ///     a permissive one.
    init(deeplinkScheme: String, deeplinkHost: String? = nil) {
        self.deeplinkScheme = deeplinkScheme
        self.deeplinkHost = deeplinkHost
    }

    /// - Parameters:
    ///   - theme: your own theme. The point of the demo is seeing the bubbles
    ///     in your colours and type, not in a sandbox's.
    ///   - onDeeplink: where a hand-off lands. Printing it is enough to start.
    func makeHost(
        theme: TanyaAITheme,
        onDeeplink: @escaping (URL) -> Void
    ) -> TanyaAIHost {
        TanyaAIHost(
            theme: theme,
            authorizationService: authorization,
            deeplinkScheme: deeplinkScheme,
            deeplinkHost: deeplinkHost,
            // A new session per presentation: the feature takes ownership of
            // the callback and closes the session when it is dismissed.
            makeSession: { MockTanyaAIChatSession.sandbox() },
            onDeeplink: onDeeplink
        )
    }

    /// Opens straight into every bubble, for a screenshot or a review.
    ///
    /// The same thing happens if the customer types "showcase", so this is a
    /// shortcut rather than a separate mode.
    func makeShowcaseHost(
        theme: TanyaAITheme,
        onDeeplink: @escaping (URL) -> Void
    ) -> TanyaAIHost {
        TanyaAIHost(
            theme: theme,
            authorizationService: authorization,
            deeplinkScheme: deeplinkScheme,
            deeplinkHost: deeplinkHost,
            initialPrompt: "showcase",
            makeSession: { MockTanyaAIChatSession.sandbox() },
            onDeeplink: onDeeplink
        )
    }
}
#endif
