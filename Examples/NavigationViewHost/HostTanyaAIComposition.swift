import Foundation
import TanyaAI

/// Composition root for the host application.
///
/// Build this once per scene and inject it downward. Never build it inside a
/// SwiftUI `body`: that recreates the transport and the authorization service
/// on every render.
final class HostTanyaAIComposition {
    let dependencies: TanyaAIDependencies
    let configuration: TanyaAIConfiguration

    init(
        requestFactory: HostTanyaAIRequestFactory,
        authorizing: HostTransactionAuthorizing,
        sessionConfiguration: URLSessionConfiguration,
        securityDelegate: HostTanyaAISecurityDelegate?,
        messagePath: String
    ) {
        dependencies = TanyaAIDependencies(
            streamingTransport: HostTanyaAIStreamingTransport(
                requestFactory: requestFactory,
                sessionConfiguration: sessionConfiguration,
                securityDelegate: securityDelegate
            ),
            authorizationService: HostTanyaAIAuthorizationService(
                authorizing: authorizing
            ),
            theme: .host
        )
        configuration = TanyaAIConfiguration(
            messagePath: messagePath,
            initialPrompt: nil
        )
    }

    /// One presentation gateway per scene. It only holds presentation state,
    /// never the feature graph itself.
    func makePresenter() -> HostTanyaAIPresenter {
        HostTanyaAIPresenter()
    }
}
