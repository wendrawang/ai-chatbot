import Foundation
import TanyaAI
import imi_dolphin_livechat_ios

/// Composition root for a host whose chat runs on 3Dolphins.
///
/// Build it once per signed-in session and inject it downward. It is the only
/// place that knows Tanya AI is driven by a vendor session; screens depend on
/// the `TanyaAIHost` it hands back and nothing else.
///
/// What it does *not* do is call `setupConnection`. That carries credentials,
/// is called once for the application, and belongs at launch - see the README.
final class ThreeDolphinsTanyaAIComposition {
    private let profile: DolphinProfile
    private let botId: String?
    private let deeplinkScheme: String
    private let deeplinkHost: String?

    /// - Parameter profile: the signed-in customer, built by the host. Never
    ///   invented here: the name and email in it are what the agent sees when
    ///   a conversation is escalated to a human.
    init(
        profile: DolphinProfile,
        botId: String? = nil,
        deeplinkScheme: String,
        deeplinkHost: String? = nil
    ) {
        self.profile = profile
        self.botId = botId
        self.deeplinkScheme = deeplinkScheme
        self.deeplinkHost = deeplinkHost
    }

    /// One host per signed-in session.
    ///
    /// `makeSession` is a factory rather than a fixed instance: a vendor
    /// session cannot be shared between presentations, because the feature
    /// takes ownership of its callback and ends the session on dismissal.
    func makeHost(
        theme: TanyaAITheme,
        onDeeplink: @escaping (URL) -> Void
    ) -> TanyaAIHost {
        TanyaAIHost(
            theme: theme,
            deeplinkScheme: deeplinkScheme,
            deeplinkHost: deeplinkHost,
            makeSession: { [profile, botId] in
                ThreeDolphinsChatSessionAdapter(profile: profile, botId: botId)
            },
            onDeeplink: onDeeplink
        )
    }
}
