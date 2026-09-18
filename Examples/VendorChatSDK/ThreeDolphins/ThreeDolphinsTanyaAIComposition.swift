import Foundation
import TanyaAI
import imi_dolphin_livechat_ios

/// Retain one composition per signed-in user; configure the SDK before using it.
final class ThreeDolphinsTanyaAIComposition {
    private let profile: DolphinProfile
    private let mapMessage: ThreeDolphinsChatSessionAdapter.MessageMapper
    private let deeplinkScheme: String
    private let deeplinkHost: String?

    init(
        profile: DolphinProfile,
        deeplinkScheme: String,
        deeplinkHost: String? = nil,
        mapMessage: @escaping ThreeDolphinsChatSessionAdapter.MessageMapper
    ) {
        self.profile = profile
        self.deeplinkScheme = deeplinkScheme
        self.deeplinkHost = deeplinkHost
        self.mapMessage = mapMessage
    }

    func makeHost(
        theme: TanyaAITheme,
        authorizationService: TanyaAIAuthorizationService? = nil,
        silentGreeting: String? = nil,
        onDeeplink: @escaping (URL) -> Void
    ) -> TanyaAIHost {
        TanyaAIHost(
            theme: theme,
            authorizationService: authorizationService,
            deeplinkScheme: deeplinkScheme,
            deeplinkHost: deeplinkHost,
            makeSession: { [profile, mapMessage] in
                ThreeDolphinsChatSessionAdapter(
                    profile: profile,
                    silentGreeting: silentGreeting,
                    mapMessage: mapMessage
                )
            },
            onDeeplink: onDeeplink
        )
    }
}
